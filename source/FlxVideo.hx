#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import openfl.events.Event;
#if VIDEOS_ALLOWED
import vlc.VlcBitmap;
#end
#end
import flixel.FlxBasic;
import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import flixel.util.FlxColor;
import openfl.utils.Assets;

class FlxVideo extends FlxBasic {
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void = null;
	
	#if desktop
	public var vlcBitmap:VlcBitmap;
	public var skipText:TextField;
	public var disabled:Bool = false;
	#end

	public function new(name:String, startStopped:Bool = false) {
		super();

		#if web
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function() {
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
			if(event.info.code == "NetStream.Play.Complete") {
				netStream.dispose();
				if(FlxG.game.contains(player)) FlxG.game.removeChild(player);

				if(finishCallback != null) finishCallback();
			}
		});
		netStream.play(name);

		#elseif desktop
		// by Polybius, check out PolyEngine! https://github.com/polybiusproxy/PolyEngine

		vlcBitmap = new VlcBitmap();
		vlcBitmap.set_height(FlxG.stage.stageHeight);
		vlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));

		vlcBitmap.onComplete = onVLCComplete;
		vlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, fixVolume);
		vlcBitmap.repeat = 0;
		vlcBitmap.inWindow = false;
		vlcBitmap.fullscreen = false;
		fixVolume(null);

		FlxG.addChildBelowMouse(vlcBitmap);
		vlcBitmap.play(checkFile(name));
		if(startStopped)
		{
			vlcBitmap.onVideoReady = function()
			{
				vlcBitmap.pause();
			};
		}

		skipText = new TextField();
		skipText.text = "Hold ANY to Skip Cutscene";
		skipText.defaultTextFormat = new TextFormat('_sans', 32, FlxColor.WHITE, false, false, false, "", "", TextFormatAlign.CENTER, 0, 0, 0, 0); //hello mario
		skipText.alpha = 0;
		skipText.width = FlxG.width;
		skipText.y += 600;
		skipText.selectable = false;
		skipText.mouseEnabled = false;
		FlxG.addChildBelowMouse(skipText);
		#end
	}

	#if desktop
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}
	
	public function onFocus() {
		if(vlcBitmap != null && !disabled) {
			vlcBitmap.resume();
		}
	}
	
	public function onFocusLost() {
		if(vlcBitmap != null && !disabled) {
			vlcBitmap.pause();
		}
	}

	function fixVolume(e:Event)
	{
		// shitty volume fix
		vlcBitmap.volume = 0;
		if(!FlxG.sound.muted && FlxG.sound.volume > 0.01 /*&& !disabled*/) { //Kind of fixes the volume being too low when you decrease it
			vlcBitmap.volume = FlxG.sound.volume * 0.5 + 0.5;
		}
	}

	public function onVLCComplete()
	{
		vlcBitmap.stop();

		// Clean player, just in case!
		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
		}

		if(FlxG.game.contains(skipText))
		{
			FlxG.game.removeChild(skipText);
		}

		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	
	function onVLCError()
		{
			trace("An error has occured while trying to load the video.\nPlease, check if the file you're loading exists.");
			if (finishCallback != null) {
				finishCallback();
			}
		}
	#if android
                 AddA+B("to skip the video when stuck//A to skip videohx\nPvideo B+to go exit/
}
