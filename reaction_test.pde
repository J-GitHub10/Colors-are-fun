import java.util.Collections;
import java.util.ArrayList;
import java.util.List;

int squareSize = 50;
int x, y;  // Coordinates of the square
boolean squareClicked = false;
long startTime, reactionTime, menuTime;
int squaresPerGroup = 3;
int squaresInCurrentGroup = 0;
int currentGroup = 0; // Start with the first group
Table table; // table
int participantNum = 0;

List<Integer> squareColors; // List to store square colors
boolean isWhiteBackground = true; // Flag to track background color
boolean started = false; // Program start bool

 /* COLOR CODES (RGB)
  color(88, 101, 242);        //Discord Blue
  color(255,69,0);            //Reddit Red 
  color(77, 217, 100);        //iOS Green

  color(255, 255, 255);       //Chrome Light Mode (white)
  color(53, 54, 58);          //Chrome Dark Mode
  */

void setup() {
  fullScreen();
  noStroke();
  
  table = new Table();
  
  table.addColumn("participant");
  table.addColumn("background_color");
  table.addColumn("button_color");
  table.addColumn("reaction_time");


  // Initialize the list with colors
  squareColors = new ArrayList<>();
  squareColors.add(color(255,69,0));     // Red color (Reddit)
  squareColors.add(color(77, 217, 100)); // Green color (iOS)
  squareColors.add(color(88, 101, 242)); // Blue color (Discord)

  // Shuffle the list using Collections.shuffle
  Collections.shuffle(squareColors);

  // Randomly set the background color
  isWhiteBackground = random(1) > 0.5;

  // Start the first square
  x = (int) random(width - squareSize);
  y = (int) random(height - squareSize);
  squareClicked = false;
  startTime = millis();
}


void draw() {
  if (started) {
    background(isWhiteBackground ? 255 : 0); // Set background color based on the flag
    if (!squareClicked) {
      fill(squareColors.get(currentGroup));
      rect(x, y, squareSize, squareSize);
    }
  } else {
    textSize(20);
    text("In this experiment all you have to do is use the mouse", 500, 400);
    text("to click the colored squares as quickly as possible", 500, 420);
    text("Click to start", 500, 500);
    rect(650, 470, squareSize, squareSize);
  }
}

void mousePressed() {
  if (!squareClicked && started) {
    // Check if the mouse coordinates are within the square
    if (mouseX >= x && mouseX <= x + squareSize && mouseY >= y && mouseY <= y + squareSize) {
      reactionTime = millis() - startTime - menuTime;
      menuTime = 0;
      String colorName = getColorName(currentGroup);
      String backgroundColor = isWhiteBackground ? "white" : "black";
      println("Your reaction time to " + colorName + " square on " + backgroundColor + " background: " + reactionTime + " milliseconds");
      
      TableRow newRow = table.addRow();
      newRow.setInt("participant", participantNum);
      newRow.setString("background_color", backgroundColor);
      newRow.setString("button_color", colorName);
      newRow.setFloat("reaction_time", reactionTime);
      
      saveTable(table, "data/colors.csv");
      
      
      squareClicked = true;

      // Wait for a moment before showing the next square
      new java.util.Timer().schedule(
          new java.util.TimerTask() {
            @Override
            public void run() {
              nextSquare();
            }
          },
          1000
      );
    }
  } else if (!squareClicked && !started) {
    if (mouseX >= 650 && mouseX <= 650 + squareSize && mouseY >= 470 && mouseY <= 470 + squareSize) {
      started = true;
      menuTime = millis();
    }
  }
}

void nextSquare() {
  x = (int) random(width - squareSize);
  y = (int) random(height - squareSize);
  squareClicked = false;
  startTime = millis();

  squaresInCurrentGroup++;

  if (squaresInCurrentGroup >= squaresPerGroup) {
    currentGroup++;
    squaresInCurrentGroup = 0;

    // If all groups are shown, reshuffle the colors list and toggle background color
    if (currentGroup >= squareColors.size()) {
      Collections.shuffle(squareColors);
      currentGroup = 0;
      isWhiteBackground = !isWhiteBackground; // Toggle background color
    }
  }
}

// Function to get color name based on shuffled index
String getColorName(int index) {
  if (index >= 0 && index < squareColors.size()) {
    int colorValue = squareColors.get(index);
    if (colorValue == color(255,69,0)) {
      return "Reddit Red";
    } else if (colorValue == color(77, 217, 100)) {
      return "iOS Green";
    } else if (colorValue == color(88, 101, 242)) {
      return "Discord Blue";
    }
  }
  return "Unknown";
}
