package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class SorForge extends IncomingMessage
   {
       
      
      public var isForge:Boolean;
      
      public function SorForge(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.isForge = param1.readBoolean();
      }
      
      override public function toString() : String
      {
         return formatToString("SORFORGE","isForge");
      }
   }
}
