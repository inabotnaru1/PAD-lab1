class Deliver
    include SuckerPunch::Job
    workers 10
  
    def perform(params)
        order = Coffee.find(params[:id])
        puts order.status
        order.status = "done"
        order.save
    end
  end