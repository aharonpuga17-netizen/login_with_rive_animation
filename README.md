# 🐻 Rive Animated Login Screen – Flutter

An interactive *animated login screen* built with *Flutter* and *Rive, featuring a responsive bear character that reacts to user interactions in real time using **State Machines*.

---
## 📷 Demo 

![Login Animation Demo](assets/demo1.gif)
## 🔥 Overview

This project demonstrates, step by step, the process of building an animated login interface using *Rive animations integrated into Flutter*.  
The animation responds dynamically to multiple user actions, providing visual feedback and enhancing the user experience.

---

## ⭐ Features

- 🧠 *Interactive Rive animation*
- 👀 The bear follows the cursor while typing in the email field
- 🙈 The bear covers its eyes when the password field is focused
- 🔒 Password field is hidden by default
- 👁️ Toggle button to show or hide the password
- ⚠️ If any input is invalid, the bear reacts with a worried expression
- 🎉 If both fields are valid, the bear reacts with happiness
- 🎯 Real-time animation control using *Rive State Machines*

---

## 🤖 Rive & State Machines

*Rive* is a real-time animation and design tool that allows developers to create interactive animations for any platform.

*State Machines* in Rive allow animations to react to user inputs by switching between different animation states based on triggers, booleans, or numeric values.

In this project, State Machines are used to control:
- Eye movement
- Hand covering animation
- Error and success reactions

---

## 🌐 Technologies Used

- 🐦 *Flutter* – Cross-platform UI framework by Google  
- 🎨 *Rive* – Real-time interactive animation tool  
- 🧠 *Rive State Machines* – Animation logic and reactions  
- 🎯 *FocusNode* – Detects focus changes in input fields  
- 🔍 *Regex* – Input validation for email and password  
- 👂 *Listeners* – Detect and respond to user input changes  
- 🎛️ *Controllers* – Manage animation logic and UI interaction  
- 🧑‍💻 *Visual Studio Code* – Development environment  

---

## 🛠️ Project Structure

```text
lib/
│
├── main.dart
│   └── Entry point of the application
│
├── login_screen.dart
│   └── Builds the animated login UI and handles logic
