convert_mp4_to_ogv(){
    local inFile="$1"
    local outFile="$2"
    ffmpeg -i "$inFile" -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 "$outFile"
}