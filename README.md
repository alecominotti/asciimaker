# asciimaker
ASCII HTML Animation Maker

<<<<<<< HEAD
  ______   ______   ______   __   __       __    __   ______   __  __   ______   ______    
 /\  __ \ /\  ___\ /\  ___\ /\ \ /\ \     /\ "-./  \ /\  __ \ /\ \/ /  /\  ___\ /\  == \   
 \ \  __ \\ \___  \\ \ \____\ \ \\ \ \    \ \ \-./\ \\ \  __ \\ \  _"-.\ \  __\ \ \  __<   
  \ \_\ \_\\/\_____\\ \_____\\ \_\\ \_\    \ \_\ \ \_\\ \_\ \_\\ \_\ \_\\ \_____\\ \_\ \_\ 
   \/_/\/_/ \/_____/ \/_____/ \/_/ \/_/     \/_/  \/_/ \/_/\/_/ \/_/\/_/ \/_____/ \/_/ /_/ 
=======
######  ______   ______   ______   __   __       __    __   ______   __  __   ______   ______    
 ######/\  __ \ /\  ___\ /\  ___\ /\ \ /\ \     /\ "-./  \ /\  __ \ /\ \/ /  /\  ___\ /\  == \   
 ######\ \  __ \\ \___  \\ \ \____\ \ \\ \ \    \ \ \-./\ \\ \  __ \\ \  _"-.\ \  __\ \ \  __<   
  ######\ \_\ \_\\/\_____\\ \_____\\ \_\\ \_\    \ \_\ \ \_\\ \_\ \_\\ \_\ \_\\ \_____\\ \_\ \_\ 
   ######\/_/\/_/ \/_____/ \/_____/ \/_/ \/_/     \/_/  \/_/ \/_/\/_/ \/_/\/_/ \/_____/ \/_/ /_/ 
>>>>>>> a76d3d12ff22a02b590355397690d46d6abca667
   

English:
- ASCII Maker is a script that generates an ASCII animation from a video.
- The animation is not saved as a video or gif, but as an HTML file, so it can be displayed in any web browser.
- I used the principle of John Hilliard, which consists in converting every frame of a video into ASCII Art using the jp2a tool and then concatenating those ASCII frames inside an HTML file, separating them with tags (<pre> tags in this case).
- Lastly, a JavaScript function hides every frame except the one that is being displayed, and then shows only the next one, and so on, going through all frames of the video in loop.
- As I mentioned before, I use the jp2a tool to convert every .jpg frame into a .txt ASCII frame.
- Before this conversion, I use the FFmpeg tool to create the JPG sequence from the selected video.
- At the beggining of the script, you have a few variables to customize the final output. (Size, background color, characters).
- The HTML file may take a few seconds to load in the web browser, depending on the amount of frames of the video.
- The argument management is pretty poor, but it gets the job done if you follow the instructions.
- All dependencies will be able to be installed when running the script.

Español:
- ASCII Maker es un script que genera una animación ASCII a partir de un video. 
- La animación no se guarda como un video o un gif, sino como un archivo HTML, por lo tanto puede ser reproducida desde cualquier navegador web.
- Usé el principio de John Hilliard, el cual consiste en transformar cada fotograma de un video en ASCII Art y luego concatenar esos fotogramas dentro de un archivo HTML, separándolos con tags (en este caso, tags <pre>).
- Por último, una función JavaScript se encarga de ocultar todos los fotogramas menos el que se muestra en pantalla, y luego muestra sólo el siguiente, y así sucesivamente, atravesando todos los fotogramas del video en loop.
- Como mencioné anteriormente, utilizo la herramienta jp2a para transformar cada fotograma .jpg en un fotograma .txt en ASCII.
- Antes de la conversión, utilizo la herramienta FFmpeg para crear la secuencia JPG del video seleccionado.
- Al comienzo del script hay algunas variables para perzonalizar el resultado final. (Tamaño, color de fondo, caracteres).
- El archivo HTML puede demorar unos segundos en cargar en el navegador web, dependiendo de la cantidad de fotogramas del video.
- El manejo de argumentos es bastante pobre, pero hace el trabajo si seguís las instrucciones.
- Todas las dependencias podrán ser instaladas al ejecutar el script.

Use:
	./asciimaker <path/to/video> [FPS]

	Parameters:
	[-c | --clean | -clean] = Cleans temporary files, such as .txt and .jpg sequences generated by this script.
	[-h | --help | -help] = Shows this information.

	Typing Ctrl+C during execution will stop the process and clean all temporary files created.

Examples of use:
	./asciimaker myVideo.mp4
	./asciimaker videos/nice/myVideo.avi
	./asciimaker myVideo.mp4 60
	./asciimaker myVideo.mp4 29.97
	./asciimaker -c
	./asciimaker -h

(default FPS: same as video)


Links:

HTML ASCII animation idea, by John Hilliard: 
	https://john.dev/posts/2019-02-23-ascii-face.html

jp2a tool, by Christian Stigen Larsen:
	https://github.com/cslarsen/jp2a

FFmpeg tool, by Fabrice Bellard:
	https://ffmpeg.org/

Ale Cominotti - 2020
