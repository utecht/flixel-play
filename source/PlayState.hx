package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

class PlayState extends FlxState {
	private var _player:Player;
	private var _map:TiledMap;
	private var _mWalls:FlxTilemap;
	private var _grpCoins:FlxTypedGroup<Coin>;

	override public function create():Void {
		_map = new TiledMap(AssetPaths.map__tmx);
		_mWalls = new FlxTilemap();
		_mWalls.loadMapFromArray(
			cast(_map.getLayer("background"), TiledTileLayer).tileArray,
			_map.width,
			_map.height,
			AssetPaths.tiles__png,
			_map.tileWidth,
			_map.tileHeight,
			FlxTilemapAutoTiling.OFF,
			1,
			1,
			3);
	  _mWalls.follow();
	  _mWalls.setTileProperties(2, FlxObject.NONE);
	  _mWalls.setTileProperties(3, FlxObject.ANY);
	  add(_mWalls);

		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);

		_player = new Player();

		var tmpMap:TiledObjectLayer = cast _map.getLayer("entities");
		for (e in tmpMap.objects) {
			placeEntities(e.type, e.xmlData.x);
		}
		add(_player);

		FlxG.camera.follow(_player, TOPDOWN, 1);

		super.create();
	}

	private function placeEntities(entityName:String, entityData:Xml):Void {
	   var x:Int = Std.parseInt(entityData.get("x"));
	   var y:Int = Std.parseInt(entityData.get("y"));
		 var name:String = entityData.get("name");
		 var type:String = entityData.get("type");
	   if (name == "player") {
       _player.x = x;
       _player.y = y;
	   }
		 if (type == "coin") {
			 _grpCoins.add(new Coin(x, y));
		 }
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
    FlxG.collide(_player, _mWalls);
		FlxG.overlap(_player, _grpCoins, playerTouchCoin);
	}

	private function playerTouchCoin(p:Player, c:Coin){
		if (p.alive && p.exists && c.alive && c.exists){
			c.kill();
		}
	}
}
