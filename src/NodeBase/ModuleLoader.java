package NodeBase;

public class ModuleLoader extends ClassLoader {
	
	String pathToDir;
	
	public ModuleLoader(ClassLoader systemClassLoader) {
		super(systemClassLoader);     
	}

	public Class<?> findClass(String className) throws ClassNotFoundException 
	{
		byte b[] = Utils.LoadFromFile(pathToDir + className + ".java").getBytes();
		return defineClass(className, b, 0, b.length);
	}
}