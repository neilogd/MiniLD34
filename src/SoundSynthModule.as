package  
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	 /**
	 * ...
	 * @author ...
	 */
	public class SoundSynthModule extends EventDispatcher
	{
		private var position:int = 0;
		
		// Env.
		private var envA:Number = 0.0;
		private var envD:Number = 0.0;
		private var envS:Number = 0.0;
		private var envR:Number = 0.0;
		private var envAEnd:Number = 0.0;
		private var envDEnd:Number = 0.0;
		private var envSEnd:Number = 0.0;
		private var envREnd:Number = 0.0;
		
		private var cursor:Number = 0.0;
		
		private var cycle:Number = 0.0;
		private var startCycle:Number = 0.0;
		private var endCycle:Number = 0.0;
		private var timer:Number = 0.0;
		private var totalTime:Number = 0.0;
		private var gain:Number = 0.1;
		
		public function SoundSynthModule() 
		{
			setEnv(0.1, 0.1, 0.1, 0.1);
		}
		
		public function setEnv(_a:Number, _d:Number, _s:Number, _r:Number):void
		{
			envA = _a * 44100.0;
			envD = _d * 44100.0;
			envS = _s * 44100.0;
			envR = _r * 44100.0;
			envAEnd = envA;
			envDEnd = envA + envD;
			envSEnd = envA + envD + envS;
			envREnd = envA + envD + envS + envR;
			totalTime = envA + envD + envS + envR;
		}
		
		public function setPitch(_start:Number, _end:Number):void
		{
			var doublePi:Number = Math.PI * 2.0;
			
			startCycle = doublePi / (44100.0 / _start);
			endCycle = doublePi / (44100.0 / _end);
			cycle = 0.0;
			cursor = 0.0;
		}
		
		public function lerp(a:Number, b:Number, t:Number):Number
		{
			return a + ( b - a ) * t;
		}
		
		public function getEnv()
		{
			var env:Number = 0.0;

			if( cursor < envAEnd )
			{
				env = lerp( 0.0, 1.0, ( cursor ) / envA );
			}
			else if( cursor < envDEnd )
			{
				env = lerp( 1.0, 0.5, ( cursor - envA ) / envD );
			}
			else if( cursor < envSEnd )
			{
				env = 0.5;
			}
			else if( cursor < envREnd )
			{
				env = lerp( 0.5, 0.0, ( cursor - envS ) / envR );
			}
			else
			{
				env = 0.0;
			}
			
			return env;
		}
		
		public function synthSine():Number
		{
			var doublePi:Number = Math.PI * 2.0;
			var val:Number = Math.sin(timer);
			var lerpVal:Number = cursor / totalTime;
			cycle = lerp(startCycle, endCycle, lerpVal);
			timer += cycle;
			if (timer > doublePi)
				timer -= doublePi;
			return val;
		}
		
		public function synthPulse():Number
		{
			var doublePi:Number = Math.PI * 2.0;
			var val:Number = Math.sin(timer);
			var lerpVal:Number = cursor / totalTime;
			cycle = lerp(startCycle, endCycle, lerpVal);
			timer += cycle;
			if (timer > doublePi)
				timer -= doublePi;
			return val * val * val * val;
		}
		
		public function process(outBuffer:Vector.<Number>):void
		{
			var i:int = 0;
			for (i = 0; i < outBuffer.length; ++i)
			{
				outBuffer[i] += synthPulse() * getEnv() * gain;
				
				cursor += 1.0;
			}
		}	
		
		public function isActive():Boolean
		{
			return cursor < totalTime;
		}
	}

}