import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Control para mostrar u ocultar la contraseña
  bool _obscureText = true;

  // Rive Controller e Inputs
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  // Focus Nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Timer para el debounce de la mirada
  Timer? _typingDebounce;

  // Controllers de texto
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Variables de error
  String? emailError;
  String? passError;

  @override
  void initState() {
    super.initState();

    // Listener para el Email: Baja las manos y activa el seguimiento de mirada
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isHandsUp?.change(false);
      } else {
        _isChecking?.change(false);
      }
    });

    // Listener para el Password: Sube las manos si tiene el foco
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _isHandsUp?.change(true);
      } else {
        _isHandsUp?.change(false);
      }
    });
  }

  // --- VALIDACIONES CORREGIDAS ---
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // CORRECCIÓN: Se agregó '.*' después del punto para que busque en toda la cadena
    // r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$'
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-]).{8,}$');
    return re.hasMatch(pass);
  }

  void _onLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError = isValidPassword(pass)
        ? null
        : 'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 especial';

    setState(() {
      emailError = eError;
      passError = pError;
    });

    // Quitar foco y resetear estados de animación
    FocusScope.of(context).unfocus();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 0;

    // Disparar triggers de éxito o fallo
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Para evitar overflow si sale el teclado
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // --- ANIMACIÓN RIVE ---
              SizedBox(
                width: size.width,
                height: 250,
                child: RiveAnimation.asset(
                  'assets/animated_login_bear.riv',
                  stateMachines: const ['Login Machine'],
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );
                    if (_controller != null) {
                      artboard.addController(_controller!);
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // --- CAMPO EMAIL ---
              TextField(
                controller: emailCtrl,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  _isChecking?.change(true);
                  // Calibración de mirada (0 a 100 según longitud del texto)
                  final look = (value.length * 1.5).clamp(0.0, 100.0);
                  _numLook?.value = look;

                  // Debounce para que deje de mirar si deja de escribir
                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(milliseconds: 1500), () {
                    if (mounted) _isChecking?.change(false);
                  });
                },
                decoration: InputDecoration(
                  errorText: emailError,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // --- CAMPO PASSWORD ---
              TextField(
                controller: passCtrl,
                focusNode: _passwordFocusNode,
                obscureText: _obscureText,
                onChanged: (value) {
                  // Mientras escribe pass, las manos deben estar arriba
                  _isChecking?.change(false);
                  _isHandsUp?.change(true);
                },
                decoration: InputDecoration(
                  errorText: passError,
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Olvidé mi contraseña
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- BOTÓN LOGIN ---
              MaterialButton(
                minWidth: size.width,
                height: 55,
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _onLogin,
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}