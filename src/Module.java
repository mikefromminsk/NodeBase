public class Module{

  public void load() {
    System.out.println("Module " + this.getClass() + " loading ...");
  }

  public int run(int a) {
    System.out.println("Module " + this.getClass() + " running ...");
    return a;
  }

  public void unload() {
    System.out.println("Module " + this.getClass() + " inloading ...");    
  }
}