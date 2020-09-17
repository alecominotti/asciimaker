# asciimaker

![ASCII Maker Banner](https://github.com/alecominotti/asciimaker/blob/master/resources/bannerasciimaker.png?raw=true)  

![ASCII Maker Gif](https://github.com/alecominotti/alecominotti.github.io/blob/master/images/asciimaker.gif?raw=true)  

English:
- ASCII Maker is a script that generates an HTML ASCII Art version of a video, image or gif.
- The animation is not saved as a video or gif, but as an HTML file, and it can be displayed in any web browser.
- I used the concept of John Hilliard, which consists in converting every frame of a video into ASCII Art using the jp2a tool and then concatenating those ASCII frames inside an HTML file, separating them with tags (\<pre\> tags in this case).
- Lastly, a JavaScript function hides every frame except the one that is being displayed, and then shows only the next one, and so on, going through all frames of the video in loop.
- jp2a tool converts every .jpg frame into a .txt ASCII frame.
- Before this conversion, FFmpeg tool is used to create the JPG sequence from the selected video.
- **All dependencies can be installed from the script**.
- The script allows you to use a Youtube video as an input.
- You can trim the video, specifying the desired starting and ending point.
- You can customize the final output with the script parameters. (fps, size, background color, characters and more).
- The HTML file may take a few seconds to load in the web browser, depending on the amount of frames of final output.


Español:
- ASCII Maker es un script que genera una versión HTML ASCII Art de un video, imagen o gif. 
- La animación no se guarda como un video o un gif, sino como un archivo HTML, y puede ser reproducida desde cualquier navegador web.
- Usé el concepto de John Hilliard, el cual consiste en transformar cada fotograma de un video en ASCII Art y luego concatenar esos fotogramas dentro de un archivo HTML, separándolos con tags (en este caso, tags \<pre\>).
- Por último, una función JavaScript se encarga de ocultar todos los fotogramas menos el que se muestra en pantalla, y luego muestra sólo el siguiente, y así sucesivamente, atravesando todos los fotogramas del video en loop.
- La herramienta jp2a convierte cada fotograma .jpg en un fotograma .txt en ASCII.
- Antes de esa conversión, la herramienta FFmpeg es usada para crear la secuencia JPG del video seleccionado.
- **Todas las dependencias pueden ser instaladas desde el script**.
- El script te permite usar un video de Youtube como input.
- Podés recortar el video, especificando punto de comienzo y fin deseado.
- Podés personalizar el resultado final con los parametros del script. (fps, tamaño, color de fondo, caracteres y más).
- El archivo HTML puede demorar unos segundos en cargar en el navegador web, dependiendo de la cantidad de fotogramas del resultado final.


### [Click here to watch real example in your browser](https://alecominotti.github.io/ "Ascii Maker example")

<br>

### Usage

	
```./asciimaker.sh < -i path/to/input_file | -y Youtube_URL > [ options ]```

	Options:
	[-f | --fps] = Specify frames per second of output (default: same as input).
	[-w | --width] = Specify width of output. Height is calculated automatically (default: 220).
	[-c | --chars] = Specify the characters to use when producing the ASCII output.
	[-b | --background] = Specify the bakground color for the ASCII output (dark|light. Default: black).
	[-s | --start] = Specify the starting position in the video. Position must be a time duration specification (See below).
	[-e | --end] = Specify the ending position in the video. Position must be a time duration specification (See below).
	[-C | --clean] = Cleans all temporary files, such as .txt and .jpg sequences generated by this script.
	[-h | --help] = Shows this help.
	
	Time duration specification: [<HH>:]<MM>:<SS>
	Pressing Ctrl+C during execution will stop the process and clean all temporary files created.
	Youtube videos are downloaded in the best quality possible.
	
#### Usage examples:
	./asciimaker.sh -i myVideo.mp4
	./asciimaker.sh -i videos/nice/myVideo69.avi -fps 60
	./asciimaker.sh -i myVideo.mp4 -fps 29.97 -w 256
	./asciimaker.sh -i myVideo.mp4 -b light -c ".,-'01abc"
	./asciimaker.sh -y https://www.youtube.com/watch?v=dQw4w9WgXcQ -w 170 -s 00:03 -e 00:07
	./asciimaker.sh -y https://www.youtube.com/watch?v=sjbLokqe0rA -w 140 -e 00:05
	./asciimaker.sh -C
	./asciimaker.sh -h

</br>

Currently only working on Linux.


#### Links:

- HTML ASCII Art idea, by John Hilliard: 
	https://john.dev/posts/2019-02-23-ascii-face.html

- jp2a tool, by Christian Stigen Larsen:
	https://github.com/cslarsen/jp2a

- FFmpeg tool, by Fabrice Bellard:
	https://ffmpeg.org/
	
- youtube-dl tool, by Yen Chi Hsuan, Remita Amine, Sergey M. and more: 
	http://ytdl-org.github.io/youtube-dl/about.html
  
##### Ale Cominotti - 2020
