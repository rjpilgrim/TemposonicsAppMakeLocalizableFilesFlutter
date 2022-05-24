//
//  main.swift
//  MakeLocalizableFiles
//
//  Created by Ryan Allan on 8/27/21.
//



import Foundation
print("START")
let path = FileManager.default.currentDirectoryPath
let url = URL(fileURLWithPath: path)
let fileURL = url.appendingPathComponent("TempoStringTranslations.csv")

let langsFile = "langs.csv"
let langsURL = url.appendingPathComponent(langsFile)
var langsOutput = ""

var readString: String? = try? String(contentsOf: fileURL, encoding: .utf8)

guard let readString = readString else {
  print("FAILED TO READ FILE")
  exit(-1)
}

do {
  if FileManager.default.fileExists(atPath: langsURL.path) {
    try FileManager.default.removeItem(at: langsURL)
  }
} catch let error as NSError {
  print("Error: \(error.domain)")
  exit(-1)
}

var numColumns = 0
var headerOffset = 0

for i in readString {
  print("here is i: \(i)")
  headerOffset = headerOffset + 1
  if i.isNewline {
    print("GOT NEWLINE")
    numColumns = numColumns + 1
    break
  }
  else {
    print("NOT NEWLINE")
  }
  if i == "," {
    numColumns = numColumns + 1
  }
}
let startIndex = readString.index(readString.startIndex, offsetBy: 0)

var currentIndex = startIndex
var columnTracker = 0
var ignoreRow = false
var inQuote = false
var newColumn = false
var noQuote = false

for i in readString[startIndex...] {
 // print("here is char: \(i)")
  if columnTracker == 0 {
    if i != "," {
      ignoreRow = true
    }
  }
  if newColumn && i != "\"" {
    noQuote = true
    newColumn = false
    //langsOutput.append("\"")
  }
  else if newColumn {
    newColumn = false
  }
  //print("here is ignore: \(ignoreRow)")
  if ignoreRow && i != "," && !i.isNewline {
    
  }
  else if ignoreRow && i == "," {
    columnTracker = columnTracker + 1
  }
  else if ignoreRow && i.isNewline {
    columnTracker = 0
    ignoreRow = false
  }
  else if i == "," && !inQuote {
    columnTracker = columnTracker + 1
    if columnTracker == 1 {
      newColumn = true
    }
    else if columnTracker == 2 {
      if noQuote {
        //langsOutput.append("\"")
        noQuote = false
      }
      langsOutput.append(",")
      newColumn = true
    }
    else if columnTracker == 3 {
      if noQuote {
        //langsOutput.append("\"")
        noQuote = false
      }
      langsOutput.append(",")
      newColumn = true
    }
    else if columnTracker == 4 {
      if noQuote {
        //langsOutput.append("\"")
        noQuote = false
      }
      langsOutput.append("\r\n")
    }
  }
  else if i.isNewline && !inQuote {
    columnTracker = 0
  }

  else if i == "\"" && readString[readString.index(after: currentIndex)] != "\"" && !inQuote {
    inQuote = true
    if columnTracker == 1 {
      langsOutput.append(i)
    }
    else if columnTracker == 2 {
      langsOutput.append(i)    }
    else if columnTracker == 3 {
      langsOutput.append(i)
    }
  }
  else if i == "\"" && readString[readString.index(before: readString.index(before: currentIndex))] != "\\" && readString[readString.index(after: currentIndex)] != "\"" && inQuote {
    inQuote = false
    if columnTracker == 1 {
      langsOutput.append(i)
    }
    else if columnTracker == 2 {
      langsOutput.append(i)    }
    else if columnTracker == 3 {
      langsOutput.append(i)
    }
  }
  else if inQuote && i == "\\" && readString[readString.index(after: currentIndex)] == "\"" {}
  else if columnTracker == 1 {
    langsOutput.append(i)
  }
  else if columnTracker == 2 {
    if i == "%" && readString[readString.index(after: currentIndex)] == "@" {
      langsOutput.append("{")
    }
    else if i == "@" && readString[readString.index(before: currentIndex)] == "%" {
      langsOutput.append("}")
    }
    else {
      langsOutput.append(i)
    }
  }
  else if columnTracker == 3 {
    if i == "%" && readString[readString.index(after: currentIndex)] == "@"  {
      langsOutput.append("{")
    }
    else if i == "@" && readString[readString.index(before: currentIndex)] == "%" {
      langsOutput.append("}")
    }
    else {
      langsOutput.append(i)
    }
  }
  if inQuote && i == "\r" {
    langsOutput.append("\n")
  }
  currentIndex = readString.index(after: currentIndex)
}
do {
  try langsOutput.write(to: langsURL, atomically: true, encoding: .utf8)
}
catch {
  print("TROUBLE WRITING")
}
