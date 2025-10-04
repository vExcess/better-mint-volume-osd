import 'dart:async';
import 'dart:io';

import 'package:drawlite_dart/drawlite.dart'
    show Drawlite, Event, MouseEvent, QuitEvent;
import 'package:drawlite_dart/dl.dart';
import 'package:drawlite_dart/drawlite-touch.dart';

import 'package:dcanvas/dcanvas.dart';
import 'package:dcanvas/backend/Window.dart';

late SDLWindow window;

late Drawlite dl;

var width = 260;
var height = 58;
var appScale = 1.0;
var running = true;

int prevLevel = 0;
int level = 0;
double mid = 58/2;
double speakerX = 11;
double barX = 47;
double textX = 234;
bool dragging = false;
int displayTimer = 0;

int getVolume() {
    final res = Process.runSync("amixer", "-c 1 -M -D pulse get Master".split(' '));
    final volumes = res.stdout.toString().split("%]").map((s) {
        var val = "";
        var i = s.length-1;
        while (s.codeUnitAt(i) >= 48 && s.codeUnitAt(i) <= 57) {
            val += s[i];
            i--;
        }
        return val.split("").reversed.join("");
    }).where((s) => s.isNotEmpty).toList();
    var avg = 0.0;
    for (String val in volumes) {
        avg += int.parse(val);
    }
    avg /= volumes.length;
    return avg.toInt();
}

void renderOSD() {
    // box
    strokeWeight(1);
    stroke(48);
    fill(34);
    rect(0, 0, 260, 58, 20);
    
    // speaker
    noStroke();
    fill(225);
    rect(speakerX, 23, 10, 12, 100);
    quad(
        speakerX+6, mid-6, 
        speakerX+14, mid-14, 
        speakerX+14, mid+14, 
        speakerX+6, mid+6
    );
    
    noFill();
    stroke(225);
    strokeWeight(4);
    arc(speakerX+18, mid, 8, 14, 180+90+30, 360+90-30);
    
    // bar
    noStroke();
    fill(48);
    rect(barX, mid-3, 160, 6, 20);
    
    fill(225);
    rect(barX, mid-3, level / 100 * 160, 6, 20);
    
    ellipse(barX + level / 100 * 160, mid, 11, 11);
    
    // text
    textAlign(CENTER, CENTER);
    font("sans-serif Bold", 18);
    text(level, textX, mid);    
}

void quit() {
    var isRunningFile = File("/tmp/better-mint-volume-osd.txt");
    if (!isRunningFile.existsSync()) {
        isRunningFile.createSync();
    }
    isRunningFile.writeAsStringSync("0");
    running = false;
}

void draw() {
    // check for events
    window.pollInput();

    level = getVolume();

    background(0);
    renderOSD();

    if (displayTimer / 60 > 1.5) {
        quit();
    }
    displayTimer++;
    if (dragging) {
        displayTimer = 0;
    }
    if (level != prevLevel) {
        displayTimer = 0;
        prevLevel = level;
    }

    window.render();

    if (!running) {
        noLoop();
        window.free();
    }
}

void mousePressed(MouseEvent event) {
    final mouseX = get.mouseX;
    final mouseY = get.mouseY;

    if (point_rect(mouseX, mouseY, barX, mid-9, 160, 18)) {
        dragging = true;
    }
}

void mouseDragged(MouseEvent event) {
    if (dragging) {
        level = constrain(((get.mouseX - barX) / 160 * 100).round(), 0, 100).toInt();
    }
    renderOSD();
}

void mouseReleased(MouseEvent event) {
    dragging = false;
}

void myEventHandler(Event event) {
    if (event is MouseEvent) {
        if (event.type == EventType.MouseDown) {
            dl.eventCallbacks.mousedown(event);
        } else if (event.type == EventType.MouseUp) {
            dl.eventCallbacks.mouseup(event);
        } else if (event.type == EventType.MouseMove) {
            dl.eventCallbacks.mousemove(event);
        }
    } else if (event is QuitEvent) {
        quit();
    }
}

Future<void> main() async {
    var isRunningFile = File("/tmp/better-mint-volume-osd.txt");
    if (!isRunningFile.existsSync()) {
        isRunningFile.createSync();
    }

    final contents = isRunningFile.readAsStringSync();
    if (contents == "1") {
        print("Already running.");
        return;
    } else {
        isRunningFile.writeAsStringSync("1");
    }

    var canvas = Canvas(width, height);
    dl = Drawlite(canvas);

    var windowX = 0;
    var windowY = 0;

    final getMonitorRes = Process.runSync("xdpyinfo", []);
    final monitorResBits = getMonitorRes.stdout.toString().split("\n").firstWhere((line) => line.trimLeft().startsWith("dimensions:")).split(":");
    if (monitorResBits.length > 1) {
        List<int> dimensions = monitorResBits[1].trimLeft().split(" ")[0].split("x").map((s) => int.parse(s)).toList();
        windowX = (dimensions[0] / 2 - width / 2).round();
        windowY = (dimensions[1] - height - 65).round();
    } else {
        print("Couldn't detect monitor resolution");
        quit();
    }

    initSDL(SDL_INIT_EVERYTHING);
    window = SDLWindow(
        title: "Untitled - LibrePaint 3D",
        x: windowX,
        y: windowY,
        width: canvas.width,
        height: canvas.height,
        flagsList: [
            SDL_WindowFlags.SDL_WINDOW_SHOWN, 
            SDL_WindowFlags.SDL_WINDOW_BORDERLESS, 
            SDL_WindowFlags.SDL_WINDOW_SKIP_TASKBAR, 
            SDL_WindowFlags.SDL_WINDOW_ALWAYS_ON_TOP
        ]
    );
    window.setCanvas(canvas);
    window.eventHandler = myEventHandler;

    globalizeDL(dl);

    frameRate(60);
    dl.draw = draw;  
    dl.mousePressed = mousePressed;
    dl.mouseDragged = mouseDragged;
    dl.mouseReleased = mouseReleased;
}