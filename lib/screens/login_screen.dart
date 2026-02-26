import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';//3.1 Importar el Timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //control para mostrar u ocultar la contraseña
  bool _obscureText = true;
  
  //Crear el cerebrro de la animacion 
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //2.1Variable para el recorrido de la mirada
  SMINumber? _numLook;

 //1))Crear Variables para Focusmode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
 //3.2 Timer
 Timer? _typingDebounce;

  //2)) Listeners ()
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //No tapes los ojos al ver email
        if (_isHandsUp != null) {
          _isHandsUp!.change(false);
          _numLook!.value = 50.0;
        }
      }
    });

    _passwordFocusNode.addListener(() {
  // manos arriba en password
  _isHandsUp?.change(_passwordFocusNode.hasFocus);
});
}

  @override
  Widget build(BuildContext context) {
    //para obtener el tamaño de la pantalla y usarlo para ajustar el diseño
    final Size size = MediaQuery.of(context).size;
 
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height:250,
              child: RiveAnimation.asset('assets/animated_login_bear.riv', 
              stateMachines: ['Login Machine'],
              //Al iniciar la animacion
              onInit: (artboard) {
                _controller = StateMachineController.fromArtboard(artboard, 'Login Machine');
                //Verifica que inicio bien
                if(_controller == null) return;
                //Agrega el controlador al tablero/escenario
                artboard.addController(_controller!);
                //Vincular variables
                _isChecking = _controller!.findSMI('isChecking');
                _isHandsUp = _controller!.findSMI('isHandsUp');
                _trigSuccess = _controller!.findSMI('trigSuccess');
                _trigFail = _controller!.findSMI('trigFail');
                //2.3 Vincular numLook
                _numLook =_controller!.findSMI('numLook');

              },
              
              )
              ),
              //Para separacion
              const SizedBox(height: 10),
              TextField(
                //3)asignar FocusNode al TextField
                focusNode: _emailFocusNode,
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    //No tapes los ojos al ver email
                    //_isHandsUp!.change(false);
                  }
                  if (_isChecking == null) return;
                  //Activa  el modo chisme
                  _isChecking!.change(true);
                  //2.4 Implementar numLook
                  //Ajustes de limites de 0 a 100
                  //80 como medidia de calibracion
                  final look =(value.length/80.0*100.0)
                  .clamp(0.0, 100.0);//Camp es el rango (abrazadera)
                  _numLook?.value = look;
                  
                  //3.3 Debounce: si vuelve a teclear, reinicia el contador
                  //Cancelar cualquier timer existente
                  _typingDebounce?.cancel();
                  //Crear un nuevo timer
                  _typingDebounce = Timer(const Duration (seconds: 1), (){
                    //Si se cierra la pantalla, quita el contador
                    if(!mounted)return;
                     //Mirada neutra
                  _isChecking?.change(false);
                  });
                 
                },
                //Para mostrar un tipo de tecleado
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    //Para redondear los bordes del campo de texto
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                //3)asignar FocusNode al TextField
                focusNode: _passwordFocusNode,
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    //No modo chisme
                    _isChecking!.change(false);
                  }
                  if (_isHandsUp == null) return;
                  //Arriba las manos
                  //_isHandsUp!.change(true);
                },

                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),//Cerrado o Seguro
                  suffixIcon: IconButton(
                    //if terniario
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      //Refresca el widget para mostrar u ocultar la contraseña
                      setState(() {
                        //Cambiar el estado de _obscureText para mostrar u ocultar la contraseña
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  //1.4 liberarr memoria/recursos al salir de la pantalla
  @override
  void dispose() {
    //4) Liberar los FocusNode para evitar fugas de memoria
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}