package
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;

	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.events.Event;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.TouchEvent;
	import starling.textures.Texture;

	public class Dragon_ChaseStarling extends Sprite
	{
		[Embed(source = "../assets/DragonWithClothes.png", mimeType = "application/octet-stream")]
		public static const ResourcesData: Class;

		[Embed(source = "../assets/starling.png")]
		private static const starlingImg: Class;

		private var _factory: StarlingFactory;
		private var _armature: Armature;
		private var _armatureDisplay: Sprite;

		private var _mouseX: Number = 0;
		private var _mouseY: Number = 0;
		private var _moveDir: int = 0;
		private var _dist: Number;
		private var _speedX: Number = 0;
		private var _starlingBird: Image;

		private var _head: Bone;
		private var _armR: Bone;
		private var _armL: Bone;

		public function Dragon_ChaseStarling()
		{
			_factory = new StarlingFactory();
			_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
			_factory.parseData(new ResourcesData());
		}

		private function textureCompleteHandler(e: Event): void
		{
			_armature = _factory.buildArmature("Dragon");
			_armatureDisplay = _armature.display as Sprite;

			_armatureDisplay.x = 400;
			_armatureDisplay.y = 550;
			WorldClock.clock.add(_armature);
			updateBehavior(0);

			this.addChild(_armatureDisplay);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
			this.stage.addEventListener(TouchEvent.TOUCH, mouseMoveHandler);

			_starlingBird = new Image(Texture.fromBitmap(new starlingImg()))
			this.addChild(_starlingBird);
			Mouse.hide();
			//get the bones which you want to control
			_head = _armature.getBone("head");
			_armR = _armature.getBone("armUpperR");
			_armL = _armature.getBone("armUpperL");

		}

		private function enterFrameHandler(_e: EnterFrameEvent): void
		{
			checkDist();
			updateMove();
			updateBones();
			WorldClock.clock.advanceTime(-1);
		}

		private function checkDist(): void
		{
			_dist = _armatureDisplay.x - _mouseX;
			if(_dist < 150)
			{
				updateBehavior(1)
			}
			else if(_dist > 190)
			{
				updateBehavior(-1)
			}
			else
			{
				updateBehavior(0)
			}

		}

		private function mouseMoveHandler(_e: TouchEvent): void
		{
			try
			{
				var _p: Point = _e.getTouch(stage).getLocation(stage);
				_mouseX = _p.x;
				_mouseY = _p.y;
				_starlingBird.x = _mouseX - 73;
				_starlingBird.y = _mouseY - 73;
			}
			catch(e: Error)
			{}
		}

		private function updateBehavior(dir: int): void
		{
			if(_moveDir == dir) return;
			_moveDir = dir;
			if(_moveDir == 0)
			{
				_speedX = 0;
				_armature.animation.gotoAndPlay("stand");
			}
			else
			{
				_speedX = 6 * _moveDir;
				_armature.animation.gotoAndPlay("walk");
			}
		}

		private function updateMove(): void
		{
			if(_speedX != 0)
			{
				_armatureDisplay.x += _speedX;
				if(_armatureDisplay.x < 0)
				{
					_armatureDisplay.x = 0;
				}
				else if(_armatureDisplay.x > 800)
				{
					_armatureDisplay.x = 800;
				}
			}
		}

		private function updateBones(): void
		{
			//update the bones' pos or rotation
			var r: Number = Math.PI + Math.atan2(_mouseY - _armatureDisplay.y + _armatureDisplay.height / 2, _mouseX - _armatureDisplay.x);
			if(r > Math.PI)
			{
				r -= Math.PI * 2;
			}

			_head.offset.rotation = r * 0.3
			_armR.offset.rotation = r * 0.8;
			_armL.offset.rotation = r * 1.5;
			_armature.invalidUpdate();

			_starlingBird.rotation = r * 0.2;
		}
	}
}