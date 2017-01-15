package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	private var _player:Player;
	private var _map:TiledMap;
	private var _mWalls:FlxTilemap;
	private var _grpCoins:FlxTypedGroup<Coin>;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _hud:HUD;
	private var _money:Int = 0;
	private var _health:Int = 3;
	private var _inCombat:Bool = false;
	private var _combatHud:CombatHUD;
	private var _ending:Bool;
	private var _won:Bool;

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

		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);

		_player = new Player();

		var tmpMap:TiledObjectLayer = cast _map.getLayer("entities");
		for (e in tmpMap.objects) {
			placeEntities(e.type, e.xmlData.x);
		}
		add(_player);

		FlxG.camera.follow(_player, TOPDOWN, 1);

		_hud = new HUD();
		add(_hud);

		_combatHud = new CombatHUD();
		add(_combatHud);

		super.create();
	}

	private function tiledProperties(propChildren:Xml):Map<String, Dynamic> {
		var properties: Map<String, Dynamic> = new Map();
		if(propChildren != null){
			for(element in propChildren.elements()){
				if(element != null && element.exists("name") && element.exists("value")){
					properties[element.get("name")] = element.get("value");
				}
			}
		}
		return properties;
	}

	private function placeEntities(entityName:String, entityData:Xml):Void {
	   var x:Int = Std.parseInt(entityData.get("x"));
	   var y:Int = Std.parseInt(entityData.get("y"));
		 var name:String = entityData.get("name");
		 var type:String = entityData.get("type");
		 var properties:Map<String, Dynamic> = tiledProperties(entityData.firstElement());
	   if (name == "player") {
       _player.x = x;
       _player.y = y;
	   } else if (type == "coin") {
			 _grpCoins.add(new Coin(x, y));
		 } else if (type == "enemy") {
			 _grpEnemies.add(new Enemy(x, y, properties["color"]));
		 }
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if(_ending){
			return;
		}
		if(!_inCombat){
	    FlxG.collide(_player, _mWalls);
			FlxG.collide(_grpEnemies, _mWalls);
			_grpEnemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(_player, _grpCoins, playerTouchCoin);
			FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		} else {
			if(!_combatHud.visible){
				_health = _combatHud.playerHealth;
				_hud.updateHUD(_health, _money);
				if(_combatHud.outcome == DEFEAT){
					_ending = true;
					FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
				} else if(_combatHud.outcome == VICTORY){
					_combatHud.e.kill();
					_won = true;
					_ending = true;
					FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
				} else {
					_combatHud.e.flicker();
				}
				_inCombat = false;
				_player.active = true;
				_grpEnemies.active = true;
			}
		}
	}

	private function doneFadeOut():Void {
		FlxG.switchState(new GameOverState(_won, _money));
	}

	private function playerTouchEnemy(P:Player, E:Enemy):Void {
		if(P.alive && P.exists && E.alive && E.exists && !E.isFlickering()){
			startCombat(E);
		}
	}

	private function startCombat(E:Enemy):Void {
		_inCombat = true;
		_player.active = false;
		_grpEnemies.active = false;
		_combatHud.initCombat(_health, E);
	}

	private function checkEnemyVision(e:Enemy):Void {
		if (_mWalls.ray(e.getMidpoint(), _player.getMidpoint())){
			e.seesPlayer = true;
			e.playerPos.copyFrom(_player.getMidpoint());
		} else {
			e.seesPlayer = false;
		}
	}

	private function playerTouchCoin(p:Player, c:Coin){
		if (p.alive && p.exists && c.alive && c.exists){
			_money++;
			_hud.updateHUD(_health, _money);
			c.kill();
		}
	}
}
