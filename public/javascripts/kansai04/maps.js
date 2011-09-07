function initialize() {
	with(google.maps){
		var pos = new LatLng(34.63827,135.411279);
		var map = new Map(document.getElementById("map_canvas"), {
			zoom: 16,
			center: pos,
			mapTypeId: MapTypeId.ROADMAP});
		var marker = new Marker({
			position: pos,
			map: map,
			title: "KansaiRubyKaigi04"});
		marker.setMap(map);
	}
}
