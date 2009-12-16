function makeChildVisible(parentId) {
	var parent_object = document.getElementById(parentId);
	var children = parent_object.getElementsByTagName("ul");
	children[0].style.visibility = "visible";
}
function makeChildInvisible(parentId) {
	var parent_object = document.getElementById(parentId);
	var children = parent_object.getElementsByTagName("ul");
	children[0].style.visibility = "hidden";
}