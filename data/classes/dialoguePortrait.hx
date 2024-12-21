import haxe.Json;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import mod_support_stuff.ModClass;

var json = Json.parse(Assets.getText(Paths.getPath('images/PORTRAITS/' + "bamber" + '.json')));

function new() {}