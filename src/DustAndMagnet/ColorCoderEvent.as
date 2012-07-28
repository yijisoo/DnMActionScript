package DustAndMagnet
{
	import flash.events.Event;

	public class ColorCoderEvent extends Event
	{
		public var level:String;
		public var color:uint;
		
		public function ColorCoderEvent(type:String, color:uint, level:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.level = level;
			this.color = color;
		}
	}
}