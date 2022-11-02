package kabam.rotmg.messaging.impl
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.utils.getTimer;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   
   public class JitterWatcher extends Sprite
   {
      
      private static const lineBuilder:LineBuilder = new LineBuilder();
       
      
      private var text_:TextFieldDisplayConcrete = null;
      
      private var lastRecord_:int = -1;
      
      private var ticks_:Vector.<int>;
      
      private var sum_:int;
      
      public function JitterWatcher()
      {
         this.ticks_ = new Vector.<int>();
         super();
         this.text_ = new TextFieldDisplayConcrete().setSize(14).setColor(16777215);
         this.text_.setAutoSize("left");
         this.text_.filters = [new DropShadowFilter(0,0,0)];
         addChild(this.text_);
         addEventListener("addedToStage",this.onAddedToStage);
         addEventListener("removedFromStage",this.onRemovedFromStage);
      }
      
      public function record() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = getTimer();
         if(this.lastRecord_ == -1)
         {
            this.lastRecord_ = _loc1_;
            return;
         }
         var _loc2_:int = _loc1_ - this.lastRecord_;
         this.ticks_.push(_loc2_);
         this.sum_ += _loc2_;
         if(this.ticks_.length > 50)
         {
            _loc3_ = this.ticks_.shift();
            this.sum_ -= _loc3_;
         }
         this.lastRecord_ = _loc1_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener("enterFrame",this.onEnterFrame);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener("enterFrame",this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this.text_.setStringBuilder(lineBuilder.setParams("JitterWatcher.desc",{"jitter":this.jitter()}));
      }
      
      private function jitter() : Number
      {
         var _loc3_:int = this.ticks_.length;
         if(_loc3_ == 0)
         {
            return 0;
         }
         var _loc1_:Number = this.sum_ / _loc3_;
         var _loc4_:* = 0;
         for each(var _loc2_ in this.ticks_)
         {
            _loc4_ += (_loc2_ - _loc1_) * (_loc2_ - _loc1_);
         }
         return int(Math.sqrt(_loc4_ / _loc3_) * 10) / 10;
      }
   }
}
