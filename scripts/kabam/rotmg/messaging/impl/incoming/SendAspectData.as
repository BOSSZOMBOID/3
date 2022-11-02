package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class SendAspectData extends IncomingMessage
   {
       
      
      public var anubisStacks:int;
      
      public function SendAspectData(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.anubisStacks = param1.readInt();
      }
      
      override public function toString() : String
      {
         return "";
      }
   }
}
