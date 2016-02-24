package app.VK;

import java.util.List;

public class Wall {

    class Likes{
        public int count;
    }

    class Item{
        public int id;
        public Likes likes;
    }

    class Response{
        public int count;
        public List<Item> items;
    }

    Response response;
}
