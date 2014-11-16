var disqus_shortname = 'culdevu';

window.onload = function() {
	{
		link = document.createElement( "link" );
		link.href = "main.css";
		link.type = "text/css";
		link.rel = "stylesheet";
		link.media = "screen,print";
		document.getElementsByTagName("head")[0].appendChild( link );
	}

	document.body.style.background = "#262626";

	var dom = document.getElementsByTagName("body")[0];
	var originalText = dom.innerHTML;
	var newText = "<div id='content' style='font-size: 0;'> \
			<span id='header'> \
				<span id='logo' class='dark' onclick='onClickLogo()'>CulDeVu</span> \
				<span style='width: 480px; display: inline-block;'> \
					<span id='quote' class='dark'>99% math and code</span> \
					<div id='navbar' class='light'> \
						<span id='0' class='navbutton' onmousedown='m_down(this)'>HOME</span> \
						<span id='1' class='navbutton' onmousedown='m_down(this)'>PROJECTS</span> \
						<span id='2' class='navbutton' onmousedown='m_down(this)'>ARTICLES</span> \
						<span id='3' class='navbutton' onmousedown='m_down(this)'>ABOUT</span>  \
					</div> \
				</span> \
			</span> \
			<span id='body' class='light'>";
	newText += originalText;
	newText += "</span>";
	newText += "<div id='copywrite'>Copyright &copy; 2014 Daniel Taylor, All Rights Reserved</div>";
	newText += "</div>";
	dom.innerHTML = newText;

	var imgDom = document.getElementsByTagName("img");
	for (var i = 0; i < imgDom.length; ++i) {
		var att = document.createAttribute("src");
		att.value = imgDom[i].getAttribute("lazy");
		imgDom[i].setAttributeNode(att);
	}

	disqusTags = document.getElementById("disqus_thread");
	if (disqusTags != null)
		loadDisqus();
}

function onClickLogo()
{
	window.location.href = "http://djtaylor.me";
}

function loadDisqus() {
    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
    dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
}

/*function loadHomePage()
{
	xmlRequest = new XMLHttpRequest();
	xmlRequest.open("GET", "articles.xml", false);
	xmlRequest.send();
	xmlDoc = xmlRequest.responseXML;

	alert(xmlDoc);

	document.getElementById("body").innerHTML = xmlDoc;
}*/

function m_down(button) {
	var urls = new Array("http://culdevu.github.io/index.html", 
						 "http://culdevu.github.io/projects.html", 
						 "http://culdevu.github.io/blog.html", 
						 "http://culdevu.github.io/about.html");

	var x = parseInt(button.getAttribute("id"));
	window.location.href = urls[x];
}