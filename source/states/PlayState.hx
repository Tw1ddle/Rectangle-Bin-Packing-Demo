package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

import binpacking.NaiveShelfPack;

class PlayState extends FlxState {
	private var eventText:TextItem;
	private var buttonsGroup:FlxTypedSpriteGroup<TextButton>;
	
	override public function create():Void {
		super.create();
		
		buttonsGroup = new FlxTypedSpriteGroup<TextButton>();
		
		//refreshBannerButton = new TextButton(0, 0, "Refresh Banner", onRefreshBannerClick);
		
		var buttons:Array<TextButton> = [];
		
		var x:Float = 0;
		for (button in buttons) {
			button.x = x;
			button.scale.set(1, 4);
			button.updateHitbox();
			button.label.offset.y = -20;
			x += button.width + 30;
			buttonsGroup.add(button);
		}
		
		buttonsGroup.screenCenter(FlxAxes.X);
		buttonsGroup.y = FlxG.height * 0.75;
		add(buttonsGroup);
		
		var msg:String = "Packing State";
		var substateText:TextItem = new TextItem(0, 0, msg, 14);
		substateText.screenCenter(FlxAxes.XY);
		add(substateText);
		
		eventText = new TextItem(0, 0, "Initializing...", 12);
		add(eventText);
		
		bgColor = FlxColor.BLACK;
	}
	
	public function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	public function clearLog():Void {
		eventText.text = "Waiting...";
	}
}