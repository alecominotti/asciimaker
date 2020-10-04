# asciimaker
![ASCII Maker Gif](https://github.com/alecominotti/alecominotti.github.io/blob/master/images/asciimaker.gif?raw=true)  

###### English:
- ASCII Maker is a script that generates an HTML ASCII Art version of a video, image or gif.
- The animation is not saved as a video or gif, but as an HTML file, and it can be displayed in a web browser.
- I used the concept of John Hilliard, which consists in converting every frame of a video into ASCII Art using the jp2a tool and then concatenating those ASCII frames inside an HTML file, separating them with tags (\<pre\> tags in this case).
- Then a JavaScript function hides every frame except the one that is being displayed, and then shows only the next one, and so on, going through all frames of the video in loop.
- You can use a Youtube video as an input.
- You can customize the final output with the script parameters. (fps, size, background color, characters trimming and more).
- The HTML file may take a few seconds to load in the web browser, depending on the amount of frames of the final output.
- All dependencies can be installed from the script.


###### Español:
- ASCII Maker es un script que genera una versión HTML ASCII Art de un video, imagen o gif. 
- La animación no se guarda como un video o un gif, sino como un archivo HTML, y puede ser reproducida desde un navegador web.
- Usé el concepto de John Hilliard, el cual consiste en transformar cada fotograma de un video en ASCII Art y luego concatenar esos fotogramas dentro de un archivo HTML, separándolos con tags (en este caso, tags \<pre\>).
- Luego una función JavaScript se encarga de ocultar todos los fotogramas menos el que se muestra en pantalla, y luego muestra sólo el siguiente, y así sucesivamente, atravesando todos los fotogramas del video en loop.
- Podés usar un video de Youtube como input.
- Podés personalizar el resultado final con los parametros del script. (fps, tamaño, color de fondo, caracteres punto de inicio, punto de fin y más).
- El archivo HTML puede demorar unos segundos en cargar en el navegador web, dependiendo de la cantidad de fotogramas del resultado final.
- Todas las dependencias pueden ser instaladas desde el script.


### [Click here to watch real example in your browser](https://alecominotti.github.io/ "Ascii Maker example")

<br>

### Usage

	
```bash asciimaker.sh < -i path/to/input_file | -y "Youtube_URL" > [ options ]```

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
	bash asciimaker.sh -i myVideo.mp4
	bash asciimaker.sh -i videos/nice/myVideo69.avi -fps 60
	bash asciimaker.sh -i myVideo.mp4 -fps 29.97 -w 256
	bash asciimaker.sh -i myVideo.mp4 -b light -c ".,-'01abc"
	bash asciimaker.sh -y "https://www.youtube.com/watch?v=dQw4w9WgXcQ" -w 170 -s 00:03 -e 00:07
	bash asciimaker.sh -y "https://www.youtube.com/watch?v=sjbLokqe0rA" -w 140 -e 00:05
	bash asciimaker.sh -C
	bash asciimaker.sh -h

</br>

Compatible with Linux and Mac.


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
