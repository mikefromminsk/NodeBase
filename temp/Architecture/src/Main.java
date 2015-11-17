import java.io.*;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) throws Exception {
        new Thread(new HttpServer("C:\\Users\\Admin\\Desktop\\SimpleLoader\\ss")).start();

        new Thread(new Runnable() {

            String convertStreamToString(InputStream is) {
                Scanner s = new Scanner(is).useDelimiter("\\A");
                return s.hasNext() ? s.next() : "";
            }

            String httpGet(String urlPath) {
                try {
                    URL url = new URL(urlPath);
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    InputStream is = connection.getInputStream();
                    return convertStreamToString(is);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return null;
            }

            public void downloadFile(final String filename, final String urlString) throws IOException {
                BufferedInputStream in = null;
                FileOutputStream fout = null;
                try {
                    in = new BufferedInputStream(new URL(urlString).openStream());
                    fout = new FileOutputStream(filename);

                    final byte data[] = new byte[1024];
                    int count;
                    while ((count = in.read(data, 0, 1024)) != -1) {
                        fout.write(data, 0, count);
                    }
                } finally {
                    if (in != null)
                        in.close();
                    if (fout != null)
                        fout.close();
                }
            }

            @Override
            public void run() {
                try {
                    Thread.sleep(100);

                    String client = "http://localhost:8080/";
                    String[] modulesList = httpGet(client).split("\n");
                    new File("modules").mkdir();
                    for (int i = 0; i < modulesList.length; i++) {
                        String moduleName = new File(modulesList[i]).getName();
                        downloadFile("src\\" + moduleName, client + modulesList[i]);
                    }
/*
                    for (int i = 0; i < modulesList.length; i++) {
                        String moduleName = new File(modulesList[i]).getName();
                        String modulesPath = new File("modules").getAbsolutePath();
                        String jarURL = "jar:file:///" +modulesPath+"/" +moduleName+ "!/";
                        URL[] classUrls = new URL[]{new URL(jarURL)};

                        URLClassLoader ucl = new URLClassLoader(classUrls);
                        Class c = ucl.loadClass(moduleName.replaceAll(".jar", ""));

                        Object ob = c.newInstance();
                        Class arg2[] = {};
                        Method m2 = c.getMethod("run", arg2);
                        m2.invoke(ob, null);
                    }*/


                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();

    }
}
