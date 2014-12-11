package NodeBase;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


public class Console {

	public static void main(String[] args) {
		ModuleLoader loader = new ModuleLoader("C:\\Users\\Hist\\Desktop\\ClassLoader\\src\\", ClassLoader.getSystemClassLoader());
		
	      try {
	        
	        Class c = loader.loadClass("Module");
	        Method[] methods = c.getMethods(); 
	        for (Method method : methods) { 
	            System.out.println("Имя: " + method.getName()); 
	            System.out.println("Возвращаемый тип: " + method.getReturnType().getName()); 
	         
	            Class[] paramTypes = method.getParameterTypes(); 
	            System.out.print("Типы параметров: "); 
	            for (Class paramType : paramTypes) { 
	                System.out.print(" " + paramType.getName()); 
	            } 
	            System.out.println(); 
	        }
	        
	        Object obj = c.newInstance();
	        Class[] paramTypes = new Class[] { int.class }; 
	        Method method = c.getMethod("run", paramTypes); 
	        Object[] params = new Object[] { new Integer(10) }; 
	        Object ret = method.invoke(obj, params);
	        System.out.print("вернулось " + ((Integer)ret).toString()); 
	        
	      } catch (ClassNotFoundException e) {
	        e.printStackTrace();
	      } catch (InstantiationException e) {
	        e.printStackTrace();
	      } catch (IllegalAccessException e) {
	        e.printStackTrace();
	      } catch (NoSuchMethodException e) {
			e.printStackTrace();
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
	   
	}


}
