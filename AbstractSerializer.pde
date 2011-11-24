
public abstract class AbstractSerializer implements Serializer {
  // This class provides the typeMap implementation, along with the serialization 
  //  overloads so each derrived class doesn't have to implement the non-default versions.
  
  protected class TypeMap extends HashMap< String, Serializable > {}
  protected TypeMap types = new TypeMap(); // A mapping of registered type names to template serializable objects for instantiation on load

  // ------------------------------------------------------------ //  
  public void registerType ( Serializable typeTemplate ) {
    types.put( typeTemplate.getType(), typeTemplate );
  }
  
  // ------------------------------------------------------------ // 
  public float   serialize ( String name, float   value ) { return serialize( name, value, 0.f   ); }
  public int     serialize ( String name, int     value ) { return serialize( name, value, 0     ); }
  public boolean serialize ( String name, boolean value ) { return serialize( name, value, false ); }
  public String  serialize ( String name, String  value ) { return serialize( name, value, ""    ); }
}
