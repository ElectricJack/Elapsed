
public class XMLSerializer extends AbstractSerializer {
  
  private PApplet        parent    = null;      // Needed to create XMLElements
  private XMLElement     xmlReader = null;      // Created when loading from an XML file
  private PrintWriter    xmlWriter = null;      // Created when saving to an XML file
  private int            depth     = 0;         // Nesting depth updated by getXmlBeginTag/getXmlEndTag and used for indentation 
  
  // ------------------------------------------------------------ //
  public XMLSerializer( PApplet parent ) {
    this.parent = parent;
  }
  
  // ------------------------------------------------------------ //
  public void  load ( String fileName, Serializable object ) {
    
    File xmlFile = new File(fileName);
    if( xmlFile.exists() ) {
      xmlReader = new XMLElement( parent, fileName );
      serialize( "root", object, true );
      xmlReader = null;
    }
  }
  
  // ------------------------------------------------------------ //
  public void  save ( String fileName, Serializable object ) { 
    xmlWriter = createWriter( fileName );
    serialize( "root", object );
    xmlWriter.flush();
    xmlWriter.close();
    xmlWriter = null;
  }

  // ------------------------------------------------------------ //
  public float serialize( String name, float value, float defaultValue ) {
    if( isLoading() ) {
      XMLElement child  = getChild( "float", name );
      if       ( child != null ) value = child.getFloat( "value", defaultValue );
    } else {
      xmlWriter.println( getXmlTag( "float", name, "" + value ) );
    }
    return value;
  }
  
  // ------------------------------------------------------------ //
  public int serialize( String name, int value, int defaultValue ) {
    if( isLoading() ) {
      XMLElement child = getChild( "int", name );
      if       ( child != null ) value = child.getInt( "value", defaultValue );
    } else {
      xmlWriter.println( getXmlTag( "int", name, "" + value ) );
    }
    return value;
  }
  
  // ------------------------------------------------------------ //
  public boolean serialize( String name, boolean value, boolean defaultValue ) {
    if( isLoading() ) {
      
      XMLElement child = getChild( "boolean", name );
      if       ( child != null ) {
        String  _value = child.getString( "value" );
                _value = _value.trim();
                _value = _value.toLowerCase();
                   
        if( _value != null &&
            _value.equals("true") ) value = true;
        else                        value = false;
      } else                        value = defaultValue;
    } else {
      xmlWriter.println( getXmlTag( "boolean", name, value? "true" : "false" ) );
    }
    return value;
  }
  
  // ------------------------------------------------------------ //
  public String serialize( String name, String value, String defaultValue ) {
    if( isLoading() ) {
      XMLElement child = getChild( "string", name );
      if       ( child != null )
                 value = child.getString( "value", defaultValue );
    } else {
      xmlWriter.println( getXmlTag( "string", name, value ) );
    }
    return value;
  }

  // ------------------------------------------------------------ //
  public    void serialize( String name, Serializable object ) { serialize( name, object, false ); }
  protected void serialize( String name, Serializable object, boolean root ) {
    
    if( isLoading() ) {
      // First if this is the root node, then xmlReader is already set to the correct node, but let's just 
      //  do some sanity checking anyways to make sure everything goes smoothly.
      boolean    actuallyRoot = root && xmlReader != null && xmlReader.getName().equals("root");
      XMLElement child        = actuallyRoot ? xmlReader : getChild( object.getType(), name );  
      
      // Now we should have the correct child element, but let's make sure something didn't go wrong.
      if       ( child != null ) {
        
        // Now we need to store the active node, and set it to the child node we found
        XMLElement parent    = xmlReader;
                   xmlReader = child;
                   
        // Let the object Serialize itself
        object.serialize( this );
        
        // Finally we need to set back the active node so we can continue
        xmlReader = parent;
      }
    } else {
      xmlWriter.println( getXmlBeginTag( object.getType(), name ) );
      
      // Let the object Serialize itself
      object.serialize( this );
        
      xmlWriter.println( getXmlEndTag( name ) );
    }
  }
  
  public <T extends Serializable> void serialize( String name, Vector<T> values ) {
    if( isLoading() ) {
      // Since we're loading in the list, we need to clear it first
      //  incase it already contains data
      values.clear();
      XMLElement child = getChild( "Vector", name );
      if       ( child != null ) {
        // Now we need to store the active node, and set it to the child node we found
        XMLElement parent    = xmlReader;
                   xmlReader = child;
        
        // Next we read through each of the child nodes, get the type and 
        //  instantiate an object of that type, then proceed to serialize 
        //   that object type and add it to the list of values
        for( int index = 0; index < child.getChildCount(); ++index ) {
          XMLElement   listChild = child.getChild( index );
          String       typeName  = listChild.getString( "type" );
          Serializable template  = types.get( typeName );
          T            object    = (T)template.clone();
          
          serialize( listChild.getName(), object );
          values.add( object );
        }
        
        // Finally we need to set back the active node so we can continue
        xmlReader = parent;
      }
    } else {
      xmlWriter.println( getXmlBeginTag( "Vector", name ) );
        int index = 0;
        for( Serializable object : values )
          serialize( "child_" + (index++), object );
      xmlWriter.println( getXmlEndTag( name ) );
    }
  }
  
  // ------------------------------------------------------------ //
  public <T extends Serializable> void serialize( String name, List<T> values ) {
    if( isLoading() ) {
      // Since we're loading in the list, we need to clear it first
      //  incase it already contains data
      values.clear();
      XMLElement child = getChild( "ArrayList", name );
      if       ( child != null ) {
        // Now we need to store the active node, and set it to the child node we found
        XMLElement parent    = xmlReader;
                   xmlReader = child;
        
        // Next we read through each of the child nodes, get the type and 
        //  instantiate an object of that type, then proceed to serialize 
        //   that object type and add it to the list of values
        for( int index = 0; index < child.getChildCount(); ++index ) {
          XMLElement   listChild = child.getChild( index );
          String       typeName  = listChild.getString( "type" );
          Serializable template  = types.get( typeName );
          T            object    = (T)template.clone();
          
          serialize( listChild.getName(), object );
          values.add( object );
        }
        
        // Finally we need to set back the active node so we can continue
        xmlReader = parent;
      }
    } else {
      xmlWriter.println( getXmlBeginTag( "ArrayList", name ) );
        int index = 0;
        for( Serializable object : values )
          serialize( "child_" + (index++), object );
      xmlWriter.println( getXmlEndTag( name ) );
    }
  }
  
  // ------------------------------------------------------------ //
  protected boolean isLoading() { return xmlReader != null; }
  // ------------------------------------------------------------ //
  // Attempts to get a child of xmlReader with the specified type 
  //  and name attributes.
  private XMLElement getChild( String type, String name ) {
    // We must have an active node to read from
    if( xmlReader == null ) return null;
    
    // First try to get the child by name, and bail if we can't find it.
    XMLElement child =  xmlReader.getChild( name );
    if       ( child == null ) return null;
    
    // Next check the type to make sure it's what we expect, if it 'aint, then bail.
    String childType = child.getStringAttribute("type");
    if( !childType.equals( type ) ) return null;
    
    // Finally, everything looks good so return our element
    return child;
  }
  
  // ------------------------------------------------------------ //
  // XML Tag-building helper functions
  private String getXmlTag      ( String type, String name, String value ) { return getIndent() + "<"  + name + " type=\"" + type + "\" value=\"" + value + "\" />"; }
  private String getXmlBeginTag ( String type, String name )               { String beginTag = getIndent() + "<"  + name + " type=\"" + type + "\">"; ++depth; return beginTag; }
  private String getXmlEndTag   (              String name )               { --depth; return getIndent() + "</" + name + ">"; }  
  private String getIndent      ( ) {
    String out = "";
    for( int indent=0; indent<depth; ++indent )
      out += "  ";
    return out;
  }
}
