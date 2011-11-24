
public interface Serializer {
  
  public void     registerType ( Serializable type );
  public void     save         ( String fileName, Serializable object );
  public void     load         ( String fileName, Serializable object );
  
  // ------------------------------------------------------------ //
  // Serialize integer values
  public int      serialize    ( String name, int      value  );
  public int      serialize    ( String name, int      value, int     defaultValue );
  
  // ------------------------------------------------------------ //
  // Serialize float values
  public float    serialize    ( String name, float    value  );
  public float    serialize    ( String name, float    value, float   defaultValue );
  
  // ------------------------------------------------------------ //
  // Serialize boolean values
  public boolean  serialize    ( String name, boolean  value  );
  public boolean  serialize    ( String name, boolean  value, boolean defaultValue );
  
  // ------------------------------------------------------------ //
  // Serialize string values
  public String   serialize    ( String name, String   value  );
  public String   serialize    ( String name, String   value, String  defaultValue );
  
  // ------------------------------------------------------------ //
  // Serialize any object that implements serializable
  public void     serialize    ( String name, Serializable  object );
  
  // ------------------------------------------------------------ //
  // Serialize any ArrayList of objects that all implement serializable
  // - You must register types that will be serialized with this method.
  public <T extends Serializable>
         void     serialize    ( String name, List<T>   values );
         
  public <T extends Serializable>
         void     serialize    ( String name, Vector<T> values );
}


