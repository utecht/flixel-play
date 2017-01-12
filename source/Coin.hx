package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Coin extends FlxSprite {

  public function new(?x:Float = 0, ?y:Float = 0){
    super(x, y);
    loadGraphic(AssetPaths.coin__png, false, 8, 8);
  }

  override public function update(elapsed:Float){
    super.update(elapsed);
  }
}
