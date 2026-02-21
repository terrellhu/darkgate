using System;
using System.Drawing;
using System.Drawing.Imaging;

public class ImageProcessor {
    public static void Process() {
        string[] files = new string[] {
            @"F:\code\godot\darkgate\assets\images\menu\char_main.png",
            @"F:\code\godot\darkgate\assets\images\menu\title_glow.png",
            @"F:\code\godot\darkgate\assets\images\menu\divider_ornament.png"
        };
        foreach (string file in files) {
            if (System.IO.File.Exists(file)) {
                Bitmap bmp = new Bitmap(file);
                Color bg = bmp.GetPixel(0, 0);
                bmp.MakeTransparent(bg);
                bmp.Save(file + ".temp.png", ImageFormat.Png);
                bmp.Dispose();
                System.IO.File.Delete(file);
                System.IO.File.Move(file + ".temp.png", file);
                Console.WriteLine("Processed " + file);
            }
        }
    }
}
