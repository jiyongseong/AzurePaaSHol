package AzureFilesCopy;
//reference : https://killsia.tistory.com/entry/IO-vs-NIO-performance-compare-%EC%84%B1%EB%8A%A5-%EB%B9%84%EA%B5%90
import java.io.*;
import java.io.File;

import java.nio.*;
import java.nio.file.*;
import java.nio.channels.*;
import java.nio.channels.FileChannel;
import java.nio.file.Files;

public class AzureFilesCopy {

     private static File srcFile = new File("C:\\temp\\eclipse.zip");  
     //private static File desFile = new File("C:\\tmp\\des.zip");  
     private static File desFile = new File("Z:\\small\\des.zip");  
     //private static File desFile = new File("Y:\\large\\des.zip");  
     private static int bufferSize = 8192; 
     
     public static void main(String[] args) {
            int testNum = 8;
            System.out.println("Start"); 
            long startTime = System.currentTimeMillis();
         try {
            switch (testNum)
            {
            case 1:
                    // 1. IO  
                    io();
                   break;
            case 2:
                    // 2. Scatter/Gather  
                    scatterGather();
                    break;
            case 3:
                    // 3. MappedByteBuffer  
                    mapBuffer();
                    break;
            case 4:
                    // 4. FileChannel + ByteBuffer  
                    channel();  
                    break;
            case 5:
                    // 5. ByteBuffer transferTo  
                    transferTo();
                    break;
            case 6:
                    // 6.ByteBuffer transferFrom  
                    transferFrom();  
                    break;
            case 7:
                    // 7. Files.Copy
                    filescopy();
                    break;
            case 8:
                    // 8. Runtime Command
                    runtimecopy();
                    break;
             default:
                  break;
                  
            }
         } catch (Exception e) {  
             e.printStackTrace();  
         } finally {  
             //desFile.delete();  
             long estimatedTime = System.currentTimeMillis() - startTime;
             System.out.println("Completed!");  
             System.out.println(estimatedTime + "ms");  
         }  
     }
     
     public static void io() throws Exception {  
            System.out.println("IO"); 
         FileInputStream fis = new FileInputStream(srcFile);  
         FileOutputStream fos = new FileOutputStream(desFile);  
           
         BufferedInputStream bis = new BufferedInputStream(fis, bufferSize);  
         BufferedOutputStream bos = new BufferedOutputStream(fos, bufferSize);  
           
         int read = -1;  
         while ((read = bis.read()) != -1) {  
             bos.write(read);  
         }  
           
         bos.close();  
         bis.close();  
     }  
     
     public static void scatterGather() throws Exception {  
            System.out.println("scatterGather"); 
         FileInputStream fis = new FileInputStream(srcFile);  
         FileOutputStream fos = new FileOutputStream(desFile);  
           
         ScatteringByteChannel sbc = fis.getChannel();  
         GatheringByteChannel gbc = fos.getChannel();  
           
         ByteBuffer bb = ByteBuffer.allocateDirect(bufferSize);  
         while (sbc.read(bb) != -1) {  
             bb.flip();  
             gbc.write(bb);  
             bb.clear();  
         }  
           
         fos.close();  
         fis.close();  
     }  
     public static void mapBuffer() throws Exception {  
            System.out.println("mapBuffer"); 
         FileInputStream fis = new FileInputStream(srcFile);  
         FileOutputStream fos = new FileOutputStream(desFile);  
           
         FileChannel fcIn = fis.getChannel();  
         FileChannel fcOut = fos.getChannel();  
           
         MappedByteBuffer mbb = fcIn.map(FileChannel.MapMode.READ_ONLY, 0, fcIn.size());  
         fcOut.write(mbb);  
           
         fos.close();  
         fis.close();  
     }  
     public static void channel() throws Exception {  
            System.out.println("channel"); 
         FileInputStream fis = new FileInputStream(srcFile);  
         FileOutputStream fos = new FileOutputStream(desFile);  
           
         FileChannel fcIn = fis.getChannel();  
         FileChannel fcOut = fos.getChannel();  
           
         ByteBuffer bb = ByteBuffer.allocateDirect((int) fcIn.size());  
         fcIn.read(bb);  
           
         bb.flip();  
         fcOut.write(bb);  
           
         fos.close();  
         fis.close();  
     }  

     public static void transferTo() throws Exception {  
            System.out.println("transferTo"); 
         FileInputStream fis = new FileInputStream(srcFile);  
         FileOutputStream fos = new FileOutputStream(desFile);  
           
         FileChannel fcIn = fis.getChannel();  
         FileChannel fcOut = fos.getChannel();  
           
         fcIn.transferTo(0, fcIn.size(), fcOut);  
           
         fos.close();  
         fis.close();  
     }  

     public static void transferFrom() throws Exception {  
            System.out.println("transferFrom"); 
         FileInputStream fis = new FileInputStream(srcFile);  
         FileOutputStream fos = new FileOutputStream(desFile);  
           
         FileChannel fcIn = fis.getChannel();  
         FileChannel fcOut = fos.getChannel();  
           
         fcOut.transferFrom(fcIn, 0, fcIn.size()); 
           
         fos.close();  
         fis.close();  
     }        
     
     public static void filescopy() throws Exception{
            System.out.println("Files.Copy"); 
            Files.copy(srcFile.toPath(), desFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
     }
     
     public static void runtimecopy() throws Exception{
            /*
            Runtime rt = Runtime.getRuntime();
            String cmd[] = {"cmd.exe", "copy", srcFile.toPath().toString(), desFile.toPath().toString()};
            rt.exec(cmd);
            */
            System.out.println("Runtime Cpoy");
            ProcessBuilder processBuilder = new ProcessBuilder();
            processBuilder.command("cmd.exe", "/c" , "copy", srcFile.toPath().toString(), desFile.toPath().toString());
            processBuilder.start();
     }
}