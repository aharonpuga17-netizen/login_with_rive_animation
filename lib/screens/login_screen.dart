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

// 4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // 4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // 4.4 Acción al botón
  void _onLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Recalcular errores
    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError =
        isValidPassword(pass)
            ? null
            : 'Mínimo 8 caracteres, 1 mayúscula,  1 minúscula, 1 número y 1 caracter especial';

    // 4.5 Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // 4.6 Cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; // Mirada neutral

    // 4.7 Activar triggers
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

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
      body: SingleChildScrollView(
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
                //4.8 En lazar controller al text field
                controller: emailCtrl,

                //1.3 asignar FocusNode al TextField
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
                   //4.8 En lazar controller al text field
                  errorText:emailError,
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
                 //4.8 En lazar controller al text field
                controller: passCtrl,
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
                  //4.9 Mostrar el texto de error
                  errorText:passError,
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
              ),
              SizedBox(height:10),
              //Texto de "Olvide mi contraseña"
              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot password?",
                  //Alinearlo a la derecha
                  textAlign: TextAlign.right,
                  style:TextStyle(
                  decoration:TextDecoration.underline
                  ),
                ),
              ),
              SizedBox(height:10),

              MaterialButton(
                //Toma todo el ancho posible
                minWidth: size.width,
                height: 50,
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(12),
                ),
                onPressed: _onLogin,
              child:Text("Login", style: TextStyle(
                color:Colors.white),),
               ),
              //¿No tienes cuenta?
              SizedBox(
              width:size.width,
               child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Dont have an account?"),
                  TextButton(
                    onPressed:(){},
                    child:const Text(
                      "Register",
                      style:TextStyle(color:Colors.black,
                      //Subrayado
                      decoration:TextDecoration.underline,
                      //Para negritas
                      fontWeight:FontWeight.bold,
                      ),
                      ),
                  )
                ]),),
            ],
          ),
        ),
      ),
    );
  }
  //1.4 liberarr memoria/recursos al salir de la pantalla
  @override
  void dispose() {
    //4.11 Liberar Controller
    emailCtrl.dispose();
    passCtrl.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}