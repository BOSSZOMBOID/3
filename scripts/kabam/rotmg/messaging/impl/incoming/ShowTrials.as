package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class ShowTrials extends IncomingMessage
   {
       
      
      public var openDialog:Boolean;
      
      public function ShowTrials(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.openDialog = param1.readBoolean();
      }
      
      override public function toString() : String
      {
         return formatToString("SHOWTRIALS","openDialog");
      }
   }
}
