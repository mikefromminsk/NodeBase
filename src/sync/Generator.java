package sync;


public class Generator implements Runnable {
    Integer id;

    public Generator(int id) {
        this.id = id;
    }

    public void run() {


        for (int i=0; i<4; i++)
        {

            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                return;    //Завершение потока после прерывания
            }
            if(Thread.interrupted())  //Проверка прерывания
                return;
        }
        Block block = Sync.data.getBlock(id);
        block.threadEnd = true;
        Sync.data.putBlock(block);
        //com.example.myapplication4.app.Sync.setResult(id);
    }
}

