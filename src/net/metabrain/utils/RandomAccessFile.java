package net.metabrain.utils;

import java.io.*;
import java.util.Date;


public class RandomAccessFile {


    private static void doAccess() throws InterruptedException {
        try {
            File file = new File("c:\\1.txt");
            java.io.RandomAccessFile raf = new java.io.RandomAccessFile(file, "rw");
            byte[] buffer = new byte[16];

            raf.read(buffer, 0, 16);
            System.out.println("Read full line: " + new String(buffer));

            double t1 = new Date().getTime();
            long count = 1;
            /*
            for (int i = 0; i < 50000; i++) {
                raf.seek(i * 16);
                raf.read(buffer, 0, 16);
                raf.seek(file.length() - 16 * (i + 1));
                raf.read(buffer, 0, 16);
                count += 2;
            }*/
            Thread.sleep(500);
            System.out.println((new Date().getTime() - t1) / count) ;

            raf.read(buffer, 0, 16);
            System.out.println("Read full line: " + new String(buffer));

            raf.close();

        } catch (IOException e) {

            System.out.println("IOException:");

            e.printStackTrace();

        }

    }

    static void createFile() throws FileNotFoundException {
        PrintWriter out = new PrintWriter("c:\\1.txt");
        for (int i = 0; i < 65536000; i++) {
            out.print("0123456789ABCDEF");
        }
        out.close();
    }



    public static void main(String[] args) throws FileNotFoundException, InterruptedException {

        doAccess();
        //createFile();

    }

}
