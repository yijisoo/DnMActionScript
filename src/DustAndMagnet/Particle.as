package DustAndMagnet
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class Particle extends UIComponent
	{
		public static const PARTICLE_MOVED:String = "particleMoved";
		
		public static const standardColor:int = 0x000000;
		public static const standardRadius:Number = 8;
		
		private var tupleKey:int;
		
		public var isVisible:Boolean = true;
		private var label:SpriteLabel;
		private var shape:Shape;
		private var color:int;
		private var radius:Number;
		private var position:Point;
		
		private var dataManager:DataManager;
		
		public function Particle(tupleKey:int, dataManager:DataManager)
		{
			super();
			
			this.dataManager = dataManager;
			
			this.tupleKey = tupleKey;
			x = 0;
			y = 0;
			position = new Point(x, y);
			
			color = Particle.standardColor;
			radius = Particle.standardRadius;
			
			shape = new Shape();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawCircle(0, 0, radius);
			addChild(shape);
			label = new SpriteLabel(dataManager.getData()[tupleKey][dataManager.getPrimaryKeyIndex()], 0x9922ff);
			label.isVisible = false;
			
			this.addEventListener(MouseEvent.CLICK, mouseClickListener);
		}
		
		public function getTupleKey():int
		{
			return tupleKey;
		}
		
		public function getRadius():Number
		{
			return radius;
		}
		
		public function getLabelIsVisible():Boolean
		{
			return label.isVisible;
		}
		
		public function setRadius(radius:Number):void
		{
			this.radius = radius;
			
			shape.graphics.clear();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawCircle(0, 0, radius);
			addChildAt(shape, 0);
		}
		
		public function setColor(color:Number):void
		{
			this.color = color;
			
			shape.graphics.clear();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawCircle(0, 0, radius);
			addChildAt(shape, 0);
		}
		
		public function getPosition():Point
		{
			return position;
		}
		public function setPosition(position:Point):void
		{
			this.position = position;
			x = position.x;
			y = position.y;
		}
		
		private function mouseClickListener(e:MouseEvent):void
		{
			parent.setChildIndex(this, parent.numChildren - 1);

			if (label.isVisible == false)
			{
				addChild(label);
				label.isVisible = true;
			}
			else
			{
				removeChild(label);
				label.isVisible = false;
			}
		}
	}
}