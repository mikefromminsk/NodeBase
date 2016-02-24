package level3.image;

import level2.consolidator.Arrays;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class ImageStorage {


    static ImageStorage imageStorage;
    public static ImageStorage getInstance() {
        if (imageStorage == null)
            imageStorage = new ImageStorage();
        return imageStorage;
    }

    private static BufferedImage resizeImageWithHint(BufferedImage originalImage, int IMG_WIDTH, int IMG_HEIGHT){

        BufferedImage resizedImage = new BufferedImage(IMG_WIDTH, IMG_HEIGHT, BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D g = resizedImage.createGraphics();
        g.drawImage(originalImage, 0, 0, IMG_WIDTH, IMG_HEIGHT, null);
        g.dispose();
        g.setComposite(AlphaComposite.Src);

        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING,
                RenderingHints.VALUE_RENDER_QUALITY);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                RenderingHints.VALUE_ANTIALIAS_ON);

        return resizedImage;
    }


    static ArrayList<String> imageIndexes(BufferedImage resizedImage){
        ArrayList<String> imageIndexes = new ArrayList<>();
        for (int i = 0; i < resizedImage.getWidth(); i++) {
            for (int j = 0; j < resizedImage.getHeight(); j++) {
                int gray = resizedImage.getRGB(i, j) & 0xFF;
                imageIndexes.add(String.valueOf(gray));
            }
        }
        return imageIndexes;
    }

    static Arrays images = new Arrays();
    static Map<String, String> imageFiles = new HashMap<>();

    static String put(String imageFilePath) throws IOException {
        BufferedImage originalImage = ImageIO.read(new File(imageFilePath));
        BufferedImage resizedImage = resizeImageWithHint(originalImage, 4, 4);
        ArrayList<String> indexes = imageIndexes(resizedImage);
        String imageID = images.put(indexes);
        imageFiles.put(imageID, imageFilePath);
        return imageID;
    }

    public static void main(String[] args) {
        try {
            System.out.println(put("c:\\cart.png"));
            System.out.println(put("c:\\cart.png"));
            String donut = put("c:\\donut.png");
            String donut2 = put("c:\\donut2.png");
            System.out.println(donut);
            System.out.println(donut2);
            Map<String, Double> seq = images.findSequences(images.getArray(donut2));
            System.out.println(seq);

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

}
