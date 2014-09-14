var disqus_shortname = 'culdevu';

window.onload = function() {
	var dom = document.getElementsByTagName("body")[0];
	var originalText = dom.innerHTML;
	var newText = "<div id='content' style='font-size: 0;'> \
			<span id='header'> \
				<span id='logo' class='dark'>CulDeVu</span> \
				<span style='width: 480px; display: inline-block;'> \
					<span id='quote' class='dark'>the portfolio of Danny Taylor</span> \
					<div id='navbar' class='light'> \
						<span id='0' class='navbutton' onmousedown='m_down(this)'>HOME</span> \
						<span id='1' class='navbutton' onmousedown='m_down(this)'>PROJECTS</span> \
						<span id='2' class='navbutton' onmousedown='m_down(this)'>DEVLOG</span> \
						<span id='3' class='navbutton' onmousedown='m_down(this)'>ABOUT</span>  \
					</div> \
				</span> \
			</span> \
			<span id='body' class='light'>";
	newText += originalText;
	newText += "</span> \
		</div>";
	dom.innerHTML = newText;

	var imgDom = document.getElementsByTagName("img");
	for (var i = 0; i < imgDom.length; ++i) {
		var att = document.createAttribute("src");
		att.value = imgDom[i].getAttribute("lazy");
		imgDom[i].setAttributeNode(att);
	}

	loadDisqus();
}

function loadDisqus() {
    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
    dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
}

function m_down(button) {
	var urls = new Array("index.html", "projects.html", "blog.html", "about.html");

	var x = parseInt(button.getAttribute("id"));
	window.location.href = urls[x];
}