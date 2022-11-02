package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class ServerFull extends IncomingMessage
   {
       
      
      public var position_:int;
      
      public var count_:int;
      
      public function ServerFull(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.position_ = param1.readInt();
         this.count_ = param1.readInt();
      }
      
      override public function toString() : String
      {
         return formatToString("SERVERFULL","position_","count_");
      }
   }
}
