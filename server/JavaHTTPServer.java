import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.*;

public class JavaHTTPServer implements Runnable {
  static final File WEB_ROOT = new File(".");
  static final String FILE_NOT_FOUND = "404.html"; //When a particular file is not obtained while any API call, the server will return the content of this file

  static final String hostname = "192.168.0.203"; // Server will be hosted to the ip : 192.168.0.203:8080 and all the API calls will be made at this url
  static final int PORT = 8080;

  static final List<QRRequest> requests = new ArrayList<QRRequest>(); // We have kept this array to store the past requests that are received from the scanner
  static int hourlyRate = 4; // Hourly rate that will be used to fetch the total fare of the user

  static Parking parking = new Parking(); // A static instance of the class Parking that handles the status and values of the parking spots along with providing us the nearest parking spot

  private Socket connect; // Client Connection via Socket Class

  public JavaHTTPServer(Socket c) {
    connect = c;
  } // Constructor

  static Boolean flag = false;

  public static void main(String[] args) {
    try {
      InetAddress addr = InetAddress.getByName(hostname);
      ServerSocket serverConnect = new ServerSocket(PORT, 50, addr);
      System.out.println(
        "Server started.\nListening for connections on IP : " +
        hostname +
        ":" +
        PORT +
        "\n"
      );

      // we listen until user halts server execution
      while (true) {
        JavaHTTPServer myServer = new JavaHTTPServer(serverConnect.accept());

        System.out.println("Connecton opened. (" + new Date() + ")");

        // create dedicated thread to manage the client connection
        Thread thread = new Thread(myServer);
        thread.start();
      }
    } catch (IOException e) {
      System.err.println("Server Connection error : " + e.getMessage());
    }
  }

  // This function would start an independent thread for delay/1000 seconds and completes once the sleep is over.
  public static void setTimeoutForWaitingTime(Runnable runnable, int delay) {
    new Thread(
      () -> {
        try {
          Thread.sleep(delay);
          runnable.run();
        } catch (Exception e) {
          System.err.println(e);
        }
      }
    )
    .start();
  }

  @Override
  public void run() {
    // we manage our particular client connection
    BufferedReader in = null;
    PrintWriter out = null;
    BufferedOutputStream dataOut = null;
    String fileRequested = null;
    String params = null;

    try {
      in = new BufferedReader(new InputStreamReader(connect.getInputStream())); // Read characters from the client via input stream on the socket
      out = new PrintWriter(connect.getOutputStream()); // Get character output stream to client (for headers)
      dataOut = new BufferedOutputStream(connect.getOutputStream()); // Get binary output stream to client (for requested data)

      String input = in.readLine(); // Get first line of the request from the client
      System.out.println(input); // Parse the request with a string tokenizer
      StringTokenizer parse = new StringTokenizer(input);
      String method = parse.nextToken().toUpperCase(); // Get the HTTP method of the client

      params = parse.nextToken().toLowerCase(); // Get the query parameters

      // POST request from the Scanner
      if (method.equals("POST")) {
        if (params.equals("/") || params.equals("/?")) { // When no parameter is passed in the API call
          System.out.println("No user specified. Nothing can be done.");
        } else if (params.contains("/entry?id=")) { // For the entry POST request from the scanner
          String ID = params.replace("/entry?id=", "");
          String validity = "valid";
          String type = "entry";
          requests.add(new QRRequest(ID, validity, type, ""));
        } else if (params.contains("/exit?id=")) { // For the exit POST request from the scanner
          String[] details = params.replace("/exit?", "").split("&");
          String ID = details[0].split("=")[1];
          String entryTime = details[1].split("=")[1];
          String type = "exit";
          requests.add(new QRRequest(ID, "valid", type, entryTime));
        }
      }
      // GET request from the client
      else if (method.equals("GET")) {
        if (params.equals("/") || params.equals("/?")) { // When no parameter is passed in the API call
          System.out.println("No user specified. Nothing can be done.");
        } else if (params.contains("/check?id=")) { // For the entry or exit GET request from the client
          String id = params.replace("/check?id=", "");

          flag = true;
          // Start a thread to stop the process when there is a timeout of request
          new Thread(
            () -> {
              try {
                Thread.sleep(15000);
                flag = false;
              } catch (Exception e) {
                System.err.println(e);
              }
            }
          )
          .start();

          QRRequest foundRequest = new QRRequest("", "", "", "");
          String response = "You can't go.";

          while (flag) { // This loop will keep on checking for a response from scanner for the same user to enter/exit
            String output = "invalid";

            Integer checkCount = 10;
            Integer lengthOfRequests = requests.size();

            // Check for the last 10 records in the requests. If the same id exists with a valid flag, the user can enter/exit
            for (
              int i = lengthOfRequests - 1;
              (i > lengthOfRequests - checkCount) && (i >= 0);
              i--
            ) {
              QRRequest request = requests.get(i);
              if (id.equals(request.ID) && request.validity.equals("valid")) {
                // If a response with the same id exists, the user is valid

                output = "valid";
                foundRequest = request;
                requests.remove(i);
                break;
              }
            }
            if (output == "valid") { // The is validated successfully and can go ahead
              if (foundRequest.type.equals("entry")) { // If the user wants to enter
                response = "Enter-" + parking.getNearestSpot(); // Get the nearest available parking spot and return the details as response
              } else if (foundRequest.type.equals("exit")) { // If the user wants to exit
                response = "Exit-";
                long currentTime = System.currentTimeMillis();
                long entryTime = Long.parseLong(foundRequest.entryTime);
                double fare = Math.max(
                  4,
                  Math.round(
                    ((currentTime - entryTime) * hourlyRate) / 36000.0
                  ) /
                  100.0
                ); // Calculate the fare that the user needs to pay while exiting
                response = response + String.valueOf(fare);
              }
              flag = false;
            }
          }

          // Filling in the necessary details and headers for the outputstream's response
          out.println("HTTP/1.1 200 OK");
          out.println("Server: Java HTTP Server from Prayag : 1.0");
          out.println("Date: " + new Date());
          out.println("Content-type: text/plain");
          out.println("Content-length: " + response.length());
          out.println();
          out.flush();

          // Filling the response in the outputstream
          dataOut.write(response.getBytes());
          dataOut.flush();
        } else if (params.contains("/getparking")) { // For the UI of sensor simulation to get the status of the parkings
          var parkingString = "";
          for (int i = 0; i < parking.parkingGuide.length; i++) {
            parkingString =
              parkingString + String.join("-", parking.parkingGuide[i]) + "+";
          }

          out.println("HTTP/1.1 200 OK");
          out.println("Server: Java HTTP Server from Prayag : 1.0");
          out.println("Date: " + new Date());
          out.println("Content-type: text/plain");
          out.println("Content-length: " + parkingString.length());
          out.println();
          out.flush();

          dataOut.write(parkingString.getBytes());
          dataOut.flush();
        } else if (params.contains("/setparking?")) { // For the UI of sensor simulation to set a value to a particular parking spot
          String[] values = params.replace("/setparking?", "").split("&");

          String[] coordinates =
            values[0].replace("coordinates=", "").split("-");
          int x = Integer.parseInt(coordinates[0]);
          int y = Integer.parseInt(coordinates[1]);

          String parkingStatus = values[1].replace("status=", "");

          parking.parkingGuide[x][y] = parkingStatus;

          String response = "Parking updated.";
          out.println("HTTP/1.1 200 OK");
          out.println("Server: Java HTTP Server from Prayag : 1.0");
          out.println("Date: " + new Date());
          out.println("Content-type: text/plain");
          out.println("Content-length: " + response.length());
          out.println();
          out.flush();

          dataOut.write(response.getBytes());
          dataOut.flush();
        }
      }
    } catch (FileNotFoundException fnfe) { // Handling file not found error
      try {
        fileNotFound(out, dataOut, fileRequested);
      } catch (IOException ioe) {
        System.err.println(
          "Error with file not found exception : " + ioe.getMessage()
        );
      }
    } catch (IOException ioe) { // Handling IOException
      System.err.println("Server error : " + ioe);
    } finally {
      try {
        in.close();
        out.close();
        dataOut.close();
        connect.close();
      } catch (Exception e) {
        System.err.println("Error closing stream : " + e.getMessage());
      }
      System.out.println("Connection closed.\n");
    }
  }

  // Function for reading a file from the path
  private byte[] readFileData(File file, int fileLength) throws IOException {
    FileInputStream fileIn = null;
    byte[] fileData = new byte[fileLength];

    try {
      fileIn = new FileInputStream(file);
      fileIn.read(fileData);
    } finally {
      if (fileIn != null) fileIn.close();
    }

    return fileData;
  }

  // Function to get the file value when file not found exception occurs
  private void fileNotFound(
    PrintWriter out,
    OutputStream dataOut,
    String fileRequested
  )
    throws IOException {
    File file = new File(WEB_ROOT, FILE_NOT_FOUND);
    int fileLength = (int) file.length();
    String content = "text/html";
    byte[] fileData = readFileData(file, fileLength);

    out.println("HTTP/1.1 404 File Not Found");
    out.println("Server: Java HTTP Server from SSaurel : 1.0");
    out.println("Date: " + new Date());
    out.println("Content-type: " + content);
    out.println("Content-length: " + fileLength);
    out.println();
    out.flush();

    dataOut.write(fileData, 0, fileLength);
    dataOut.flush();

    System.out.println("File " + fileRequested + " not found");
  }
}

// Class for generating instances of the requests sent from the scanner
class QRRequest {
  String ID = "invalid";
  String validity = "invalid";
  String type = "entry";
  String entryTime = "";

  public QRRequest(String id, String val, String t, String time) {
    ID = id;
    validity = val;
    type = t;
    entryTime = time;
  }

  public static void main(String[] args) {
    System.out.println("New request created.");
  }
}

// Class for handling all the functionalities of the parking
public class Parking {
  static int ROWS = 21; // Number of rows in the parking area
  static int COLUMNS = 30; // Number of columns in the parking area

  // 2 dimensional array of parking spots that would handle the availability and unavailability of the parking spots
  static String[][] parkingGuide = {
    {
      "xx",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "xx",
    },
    {
      "ss",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pa",
      "pa",
      "pa",
      "rv",
      "pa",
    },
    {
      "pn",
      "rv",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pa",
    },
    {
      "pn",
      "rv",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pa",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pn",
    },
    {
      "pa",
      "rv",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rv",
      "pn",
    },
    {
      "pa",
      "rv",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pa",
    },
    {
      "pn",
      "rv",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pa",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pn",
    },
    {
      "pa",
      "rv",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pa",
    },
    {
      "pn",
      "rv",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pa",
      "pa",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "rv",
      "pn",
    },
    {
      "pn",
      "rv",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "rv",
      "pa",
    },
    {
      "pn",
      "rv",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "rh",
      "se",
    },
    {
      "xx",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pa",
      "pa",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "pn",
      "xx",
    },
  };

  static boolean[][] pathVisited = new boolean[ROWS][COLUMNS]; // This array will be used during the BFS while traversing through the paths

  static int[] xVal = new int[] { 0, 1, 0, -1 };
  static int[] yVal = new int[] { 1, 0, -1, 0 };
  static char[] dir = new char[] { 'E', 'S', 'W', 'N' };

  public static void Parking() {}

  // Function for converting a calculated path to user centric path/route
  public static String getPathDirections(String Dir) {
    String path = "S";
    int l = Dir.length();
    int i = 0;
    int j = 1;

    while (j < l) {
      if (Dir.charAt(i) == 'E' && Dir.charAt(j) == 'E') {
        path = path + 'S';
      }

      if (Dir.charAt(i) == 'E' && Dir.charAt(j) == 'S') {
        path = path + 'R';
      }

      if (Dir.charAt(i) == 'E' && Dir.charAt(j) == 'N') {
        path = path + 'L';
      }

      if (Dir.charAt(i) == 'W' && Dir.charAt(j) == 'W') {
        path = path + 'S';
      }

      if (Dir.charAt(i) == 'W' && Dir.charAt(j) == 'S') {
        path = path + 'L';
      }

      if (Dir.charAt(i) == 'W' && Dir.charAt(j) == 'N') {
        path = path + 'R';
      }

      if (Dir.charAt(i) == 'S' && Dir.charAt(j) == 'S') {
        path = path + 'S';
      }

      if (Dir.charAt(i) == 'S' && Dir.charAt(j) == 'E') {
        path = path + 'L';
      }

      if (Dir.charAt(i) == 'S' && Dir.charAt(j) == 'W') {
        path = path + 'R';
      }

      if (Dir.charAt(i) == 'N' && Dir.charAt(j) == 'N') {
        path = path + 'S';
      }

      if (Dir.charAt(i) == 'N' && Dir.charAt(j) == 'E') {
        path = path + 'R';
      }

      if (Dir.charAt(i) == 'N' && Dir.charAt(j) == 'W') {
        path = path + 'L';
      }
      i++;
      j++;
    }

    return path;
  }

  public static void main(String[] args) {
    System.out.println("New Parking created.");
  }

  // Algorithm for getting the nearest available parking spot. Uses queue for running a breadth-first-search algorithm in the matrix
  public static String getNearestSpot() {
    int row = 1, column = 1;
    int[] pxVal = new int[2], pyVal = new int[2];
    char[] pDir = new char[2];

    Queue<Cell> q = new LinkedList<Cell>();
    q.clear();
    q.add(new Cell(row, column, ""));
    pathVisited[row][column] = true;
    boolean flag = true;

    while (flag && !q.isEmpty()) {
      Cell cell = q.peek();
      int x = cell.first;
      int y = cell.second;
      String path = cell.path;
      q.remove();
      if (parkingGuide[x][y] == "rh") {
        pxVal = new int[] { -1, 1 };
        pyVal = new int[] { 0, 0 };
        pDir = new char[] { 'N', 'S' };
      } else if (parkingGuide[x][y] == "rv") {
        pxVal = new int[] { 0, 0 };
        pyVal = new int[] { -1, 1 };
        pDir = new char[] { 'W', 'E' };
      }

      for (int i = 0; i < pxVal.length; i++) {
        int adjx = x + pxVal[i];
        int adjy = y + pyVal[i];
        if (parkingGuide[adjx][adjy].charAt(1) == 'a') { // Available parking spot found.
          flag = false;
          pathVisited = new boolean[ROWS][COLUMNS];
          q.clear();
          var parkingNumber = (char) (65 + adjx) + String.valueOf(adjy + 1);
          return parkingNumber + "-" + getPathDirections("E" + path + pDir[i]);
        }
      }

      for (int i = 0; i < xVal.length; i++) {
        int adjx = x + xVal[i];
        int adjy = y + yVal[i];
        if (
          !pathVisited[adjx][adjy] && parkingGuide[adjx][adjy].charAt(0) == 'r'
        ) {
          q.add(new Cell(adjx, adjy, path + dir[i]));
          pathVisited[adjx][adjy] = true;
        }
      }
    }
    pathVisited = new boolean[ROWS][COLUMNS];
    q.clear();
    return "Parking full.";
  }
}

// Class for storing a cell's attributes in the queue while running BFS
class Cell {
  int first, second;
  String path = "";

  public Cell(int first, int second, String path) {
    this.first = first;
    this.second = second;
    this.path = path;
  }
}
