#!/bin/bash

echo "Name the file :"
read namefile

# Request gps coordinates
echo "GPS coordinate inputs(exemple 0.000,0.000) :"
read lat_lon
lat=$(echo $lat_lon | sed 's/ //g' | cut -d ',' -f1)
lon=$(echo $lat_lon | sed 's/ //g' | cut -d ',' -f2)

echo "Choose a radius between 1 and 32km: :"
read radiustempo


echo "What is your API key?"
read tempo_api

curl -s 'https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key='"$tempo_api"'&sort=date-posted-desc&lat='"$lat"'&lon='"$lon"'&radius='"$radiustempo"'&format=json&nojsoncallback=1&per_page=500' > curl.tempo2
#per_page (Facultatif)
#Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.

jq -r '.photos.photo[] | .server, .id, .secret, .title, .owner' curl.tempo2 > transit.json
rm curl.tempo2
sed -i 's/&/\&amp;/g' transit.json

# Nom du fichier HTML
nom_fichier=$(echo "$namefile.html")

echo "<html>" > "$nom_fichier"
echo "<head>" >> "$nom_fichier"
echo "<title>Flickr HTML</title>" >> "$nom_fichier"
echo "</head>" >> "$nom_fichier"
echo "<body>" >> "$nom_fichier"
echo "<h1>Report Flickr</h1>" >> "$nom_fichier"

# Créer un tableau HTML
echo "<table border='1'>" >> "$nom_fichier"
echo "<tr><th>Flickr html</th></tr>" >> "$nom_fichier"

###PARTIE TRAITEMENT DE LA BASE
while [ "$(wc -l < transit.json)" -gt 0 ];do
json=($(head -n 5 transit.json))
declare -a json
datejson=$(date -Ru)

echo '<tr><td><img src="https://live.staticflickr.com/'"${json[0]}"'/'"${json[1]}"'_'"${json[2]}"'.jpg"/><br >' >> "$nom_fichier"
echo "title: ${json[3]}<br >id: ${json[1]}<br >" >> "$nom_fichier"
echo "Source : https://www.flickr.com/photos/${json[4]}/${json[1]}/<br >" >> "$nom_fichier"
echo "Owner : https://www.flickr.com/people/${json[4]}/<br >" >> "$nom_fichier"
echo "</td></tr>" >> "$nom_fichier"
sed -i '1,5d' transit.json
done

rm transit.json
echo "</table>" >> "$nom_fichier"
echo "</body>" >> "$nom_fichier"
echo "</html>" >> "$nom_fichier"

echo "New page html : $nom_fichier"

exit
