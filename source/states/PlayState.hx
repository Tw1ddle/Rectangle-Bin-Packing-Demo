package states;

import binpacking.NaiveShelfPack;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class PackedRectangle extends FlxSprite {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(Std.int(Math.random() * 255), Std.int(Math.random() * 255), Std.int(Math.random() * 255)));
		
		// TODO add number/label
	}
}

class PlayState extends FlxState {
	private var naiveShelfPack:NaiveShelfPack;
	private var eventText:TextItem;
	private var buttonsGroup:FlxTypedSpriteGroup<TextButton>;
	private var rectsGroup:FlxTypedSpriteGroup<PackedRectangle>;
	
	private var failedAdds:Int;
	
	override public function create():Void {
		super.create();
		
		buttonsGroup = new FlxTypedSpriteGroup<TextButton>();
		
		rectsGroup = new FlxTypedSpriteGroup<PackedRectangle>();
		
		var buttons:Array<TextButton> = [];
		
		buttons.push(new TextButton(0, 0, "Naive Shelf", function() {
			var node = naiveShelfPack.insert(rand(10, 80), rand(5, 50));
			if (node != null) {
				addRect(node.x, node.y, node.width, node.height);
				addOccupancyText(naiveShelfPack.occupancy());
			} else {
				failedAdds++;
				addText("Failed to add node (x" + failedAdds + ")"); // Gives up on failure, you might prefer to create a new packer/bin and continue packing stuff
			}
		}));
		buttons.push(new TextButton(0, 0, "Shelf", function() {
			
		}));
		buttons.push(new TextButton(0, 0, "Guillotine", function() {
			
		}));
		buttons.push(new TextButton(0, 0, "Skyline", function() {
			
		}));
		buttons.push(new TextButton(0, 0, "Max Rects", function() {
			
		}));
		buttons.push(new TextButton(0, 0, "Reset", function() {
			init();
		}));
		
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
		substateText.screenCenter(FlxAxes.X);
		substateText.y = 30;
		add(substateText);
		
		eventText = new TextItem(0, 0, "Initializing...", 12);
		add(eventText);
		
		add(rectsGroup);
		
		init();
		
		bgColor = FlxColor.BLACK;
	}
	
	private function init():Void {
		clearLog();
		naiveShelfPack = new NaiveShelfPack(Std.int(FlxG.width / 2), Std.int(FlxG.height / 2));
		rectsGroup.clear();
		failedAdds = 0;
	}
	
	private function addOccupancyText(occupancy:Float):Void {
		var shelfPack = Std.string(naiveShelfPack.occupancy() * 100);
		
		if (shelfPack.length > 6) {
			shelfPack = shelfPack.substring(0, 5);
		}
			
		addText("Occupancy: " + shelfPack + "%");
	}
	
	private function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	private function clearLog():Void {
		eventText.text = "Waiting...";
	}
	
	private function addRect(x:Int, y:Int, width:Int, height:Int):Void {
		addText("Adding rect: " + "x:" + x + ", y:" + y + ", w:" + width + ", h:" + height);
		rectsGroup.add(new PackedRectangle(x, y, width, height));
	}
	
	private function rand(min:Int, max:Int):Int {
		return Std.int(min + Math.random() * (max - min));
	}
}