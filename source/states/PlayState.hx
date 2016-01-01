package states;

import binpacking.GuillotinePacker;
import binpacking.MaxRectsPacker;
import binpacking.NaiveShelfPacker;
import binpacking.OptimizedMaxRectsPacker;
import binpacking.Rect;
import binpacking.ShelfPacker;
import binpacking.SkylinePacker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

// Displays a rectangle that has been packed by the packer
class PackedRectangle extends FlxSpriteGroup {
	public function new(x:Int, y:Int, width:Int, height:Int, label:String) {
		super(x, y);
		
		Sure.sure(width > 0 && height > 0);
		
		var sprite = new FlxSprite();
		sprite.makeGraphic(width, height, FlxColor.fromRGB(Std.int(Math.random() * 255), Std.int(Math.random() * 255), Std.int(Math.random() * 255)));
		add(sprite);
		
		var text = new FlxText(0, 0, 0, label, 8);
		add(text);
	}
}

class PlayState extends FlxState {
	// Packing algorithms
	private var naiveShelfPack:NaiveShelfPacker;
	private var shelfPack:ShelfPacker;
	private var guillotinePack:GuillotinePacker;
	private var skylinePack:SkylinePacker;
	private var maxRectsPack:MaxRectsPacker;
	private var optimizedMaxRectsPack:OptimizedMaxRectsPacker;
	
	private var eventText:TextItem; // Info messages
	private var buttonsGroup:FlxTypedSpriteGroup<TextButton>; // User controls
	private var rectsGroup:FlxSpriteGroup; // Group for all rectangles added by a packing algorithm
	
	private var binX:Int = 0;
	private var binY:Int = 0;
	private var binWidth:Int = 0;
	private var binHeight:Int = 0;
	private var binRect:FlxSprite; // Draw the bin, for visually confirming rects are all within it
	
	private static var successCount:Int = 0; // Useful for stamping on rectangle sprites for id'ing them
	private static var failureCount:Int = 0; // How many times an algorithm fails to add a rect to its bin
	
	private static var currentTestIdx:Int = 0; // For cycling through tests
	
	override public function create():Void {
		super.create();
		
		bgColor = FlxColor.BLACK;
		
		binX = Std.int(FlxG.width / 2) - 50;
		binY = 50;
		binWidth = Std.int(FlxG.width / 2);
		binHeight = Std.int(FlxG.height / 2);
		
		buttonsGroup = new FlxTypedSpriteGroup<TextButton>();
		rectsGroup = new FlxSpriteGroup();
		rectsGroup.x = binX;
		rectsGroup.y = binY;
		binRect = new FlxSprite();
		binRect.makeGraphic(binWidth, binHeight, FlxColor.fromRGB(50, 50, 50));
		rectsGroup.add(binRect);
		
		var rand = function(min:Int, max:Int):Int {
			return Std.int(min + Math.random() * (max - min));
		}
		
		// Create user controls for 
		var buttons:Array<TextButton> = [];
		buttons.push(new TextButton(0, 0, "Naive Shelf", function() {
			var node = naiveShelfPack.insert(rand(10, 80), rand(5, 50));
			addRect(naiveShelfPack.occupancy, node);
		}));
		
		buttons.push(new TextButton(0, 0, "Shelf", function() {
			var node:Rect = shelfPack.insert(rand(10, 80), rand(5, 50), ShelfChoiceHeuristic.BestArea);
			addRect(shelfPack.occupancy, node);
		}));
		
		buttons.push(new TextButton(0, 0, "Guillotine", function() {
			var node:Rect = guillotinePack.insert(rand(10, 80), rand(5, 50), true, GuillotineFreeRectChoiceHeuristic.BestAreaFit, GuillotineSplitHeuristic.MinimizeArea);
			addRect(guillotinePack.occupancy, node);
		}));
		
		buttons.push(new TextButton(0, 0, "Skyline", function() {
			var node:Rect = skylinePack.insert(rand(10, 80), rand(5, 50), LevelChoiceHeuristic.MinWasteFit);
			addRect(skylinePack.occupancy, node);
		}));
		
		buttons.push(new TextButton(0, 0, "Max Rects", function() {
			var node:Rect = maxRectsPack.insert(rand(10, 80), rand(5, 50), FreeRectChoiceHeuristic.BestAreaFit);
			addRect(maxRectsPack.occupancy, node);
		}));
		
		buttons.push(new TextButton(0, 0, "Opt Max Rects", function() {
			var node:Rect = optimizedMaxRectsPack.insert(rand(10, 80), rand(5, 50));
			addRect(optimizedMaxRectsPack.occupancy, node);
		}));
		
		buttons.push(new TextButton(0, 0, "Tests", function() {
			addText("Running test");
			
			// Generate some rect sizes to cover the whole area of the bin (or slightly over)
			var sizes:Array<RectSize> = [];
			var totalArea:Int = binWidth * binHeight;
			var currentArea:Int = 0;
			
			while (currentArea < totalArea) {
				var w:Int = 1 + Std.int(Math.random() * 80);
				var h:Int = 1 + Std.int(Math.random() * 80);
				currentArea += w * h;
				sizes.push(new RectSize(w, h));
			}
			
			init();
			
			// Pack the shelves, choosing a random heuristic for each item
			for (size in sizes) {
				switch(currentTestIdx) {
					case 0:
						addRect(naiveShelfPack.occupancy, naiveShelfPack.insert(size.width, size.height));
					case 1:
						var heuristic = randomElement(Type.allEnums(ShelfChoiceHeuristic));
						addRect(shelfPack.occupancy, shelfPack.insert(size.width, size.height, heuristic));
					case 2:
						var h1 = randomElement(Type.allEnums(GuillotineFreeRectChoiceHeuristic));
						var h2 = randomElement(Type.allEnums(GuillotineSplitHeuristic));
						addRect(guillotinePack.occupancy, guillotinePack.insert(size.width, size.height, true, h1, h2));
					case 3:
						var heuristic = randomElement(Type.allEnums(LevelChoiceHeuristic));
						addRect(skylinePack.occupancy, skylinePack.insert(size.width, size.height, heuristic));
					case 4:
						var heuristic = randomElement(Type.allEnums(FreeRectChoiceHeuristic));
						addRect(maxRectsPack.occupancy, maxRectsPack.insert(size.width, size.height, heuristic));
					case 5:
						addRect(optimizedMaxRectsPack.occupancy, optimizedMaxRectsPack.insert(size.width, size.height));
				}
			}
			
			currentTestIdx++;
			if (currentTestIdx > 5) {
				currentTestIdx = 0;
			}
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
			x += button.width + 10;
			buttonsGroup.add(button);
		}
		
		buttonsGroup.screenCenter(FlxAxes.X);
		buttonsGroup.y = FlxG.height * 0.75;
		add(buttonsGroup);
		
		eventText = new TextItem(0, 0, "Initializing...", 12);
		add(eventText);
		
		add(rectsGroup);
		
		init();
	}
	
	private function init():Void {
		clearLog();
		
		var w = binWidth;
		var h = binHeight;
		
		naiveShelfPack = new NaiveShelfPacker(w, h);
		shelfPack = new ShelfPacker(w, h, true);
		guillotinePack = new GuillotinePacker(w, h);
		maxRectsPack = new MaxRectsPacker(w, h);
		optimizedMaxRectsPack = new OptimizedMaxRectsPacker(w, h);
		skylinePack = new SkylinePacker(w, h, true);
		
		rectsGroup.clear();
		binRect.x = 0;
		binRect.y = 0;
		rectsGroup.add(binRect); // Readd the background rect
		
		failureCount = 0;
		successCount = 0;
	}
	
	private function addRect(occupancy:Void->Float, rect:Rect):Void {
		if (rect != null) {
			var x:Int = Std.int(rect.x);
			var y:Int = Std.int(rect.y);
			var width:Int = Std.int(rect.width);
			var height:Int = Std.int(rect.height);
			Sure.sure(x >= 0 && y >= 0 && width > 0 && height > 0);
			
			addText("Packing rect " + "#" + Std.string(successCount) + " - x:" + x + ", y:" + y + ", w:" + width + ", h:" + height);
			rectsGroup.add(new PackedRectangle(x, y, width, height, Std.string(successCount++)));
			
			addOccupancyText(occupancy());
		} else {
			failureCount++;
			addText("Failed to add node (x" + failureCount + ")");
		}
	}
	
	private function addOccupancyText(occupancy:Float):Void {
		var occupancyStr = Std.string(occupancy * 100);
		if (occupancyStr.length > 6) {
			occupancyStr = occupancyStr.substring(0, 5);
		}
		addText("Occupancy: " + occupancyStr + "%");
	}
	
	private function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	private function clearLog():Void {
		eventText.text = "Waiting...";
	}
	
	private inline function randomElement<T>(array:Array<T>):T {
		Sure.sure(array != null);
		return array[Std.int(Math.random()) * (array.length - 1)];
	}
}