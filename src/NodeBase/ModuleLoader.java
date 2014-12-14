package NodeBase;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

public class ModuleLoader extends ClassLoader {
	
  public ModuleLoader(ClassLoader parent) 
  {
    super(parent);       
  }

  public Class<?> findClass(String filePath) throws ClassNotFoundException 
  {
	  String className = new File(filePath).getName().replace(".java", "");
	  try 
	  {
		  byte b[] = fetchClassFromFS(filePath);
		  return defineClass(className, b, 0, b.length);
	  } 
	  catch (FileNotFoundException ex) {
		  return super.findClass(className);
	  } 
	  catch (IOException ex) {
		  return super.findClass(className);
	  }
  }

  private byte[] fetchClassFromFS(String filePath) throws FileNotFoundException, IOException 
  {
	  return Utils.LoadFromFile(filePath).getBytes();
  }
}