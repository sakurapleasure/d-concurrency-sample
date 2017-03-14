import std.stdio;
import std.concurrency;
import std.parallelism : parallel;
import moeimgd.moeimg;
import std.file;
import std.string;
import requests;

void main(string[] args) {
	immutable string[] available_opts = ["normal", "concurrency", "parallelism"];
	if(args.length == 1) {
		writeln("needed 1 argument: ", available_opts);
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
		case "parallelism":
			foreach(article; articles.parallel()) {
				downloadImg(article, "imgs-parallel");
			}
			break;
		default:
			writeln("needed ", available_opts);
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
			auto content = getContent(image.getURL());
			auto f = File(file, "wb");
			f.rawWrite(content.data);
			writeln("done: ", image.filename);
		} else {
			writeln("exists: ", image.filename);
		}
	}
}