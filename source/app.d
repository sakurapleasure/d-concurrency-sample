import std.stdio;
import std.concurrency;
import moeimgd.moeimg;
import std.file;
import std.string;
import std.net.curl;

void main(string[] args) {
	if(args.length == 1) {
		writeln("needed 1 argument: normal or concurrency");
		return;
	}
	auto articles = getArticles(1);

	switch(args[1]) {
		case "normal":
			foreach(article; articles) {
				downloadImg(article, "imgs-normal"); // non-並列
			}
			break;
		case "concurrency":
			foreach(article; articles) {
				spawn(&downloadImg, article, "imgs-concurrency"); // 並列
			}
			break;
		default:
			writeln("needed \"normal\" or \"concurrency\"");
	}
}

void downloadImg(Article article, string dir) {
	if(!exists(dir)) mkdir(dir);
	if(!exists(dir~"/"~article.name)) mkdir(dir~"/"~article.name);
	writeln("start: ", article.name);
	Image[] images = getImages(article);

	foreach(image; images) {
		auto file = format("%s/%s/%s", dir, article.name, image.filename);
		if(!exists(file)) {
			download(image.getURL(), file);
			writeln("done: ", image.filename);
		} else {
			writeln("exists: ", image.filename);
		}
	}
}