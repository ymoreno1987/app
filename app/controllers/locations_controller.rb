class LocationsController < ApplicationController
  def index
    # get all locations in the table locations
    @locations = Location.all

    # to json format
    @locations_json = @locations.to_json
  end

  def new
    # default: render ’new’ template (\app\views\locations\new.html.haml)
  end

  def create
    # create a new instance variable called @location that holds a Location object built from the data the user submitted
    @location = Location.new(location_params)

    # if the object saves correctly to the database
    if @location.save
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully created.'
    else
      # redirect the user to the new method
      render action: 'new'
    end
  end

  def edit
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])
  end

  def update
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # if the object saves correctly to the database
    if @location.update_attributes(location_params)
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully updated.'
    else
      # redirect the user to the edit method
      render action: 'edit'
    end
  end

  def destroy
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # delete the location object and any child objects associated with it
    @location.destroy

    # redirect the user to index
    redirect_to locations_path, notice: 'Location was successfully deleted.'
  end

  def destroy_all
    # delete all location objects and any child objects associated with them
    Location.destroy_all

    # redirect the user to index
    redirect_to locations_path, notice: 'All locations were successfully deleted.'
  end

  def show
    # default: render ’show’ template (\app\views\locations\show.html.haml)
  end

  def ejercicioa
    @Latitud = params[:Lat]
    @Longitud = params[:Lon]
    @Radio = params[:Rad]
    @locations = Location.all
    array = []
    auxLat = @Latitud.to_f
    auxLon = @Longitud.to_f
    auxRad = @Radio.to_f

    @locations.each{ |loc|
      disLat = (loc.latitude - auxLat) * (Math::PI / 180)
      disLong = (loc.longitude - auxLon) * (Math::PI / 180)
      a = Math.sin(disLat/2) * Math.sin(disLat/2) + Math.cos((auxLat) * Math::PI/180) * Math.cos((loc.latitude) * Math::PI/180) * Math.sin(disLong/2) * Math.sin(disLong/2)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      dis = 6371 * 1000 * c

      if(dis <= auxRad)
        array << loc
      end
    }
    @locations = array
    if array.empty?
      @mensaje = "No se encontro ningun punto de interes cercanos"
    end
  end

    def ejerciciob
      @locations = Location.all
      @casa = Location.where(name: 'Casa')

      num = @locations.length
      if num <= 3
        @mensaje = "El numero de puntos de interes debe ser mayor o igual a 3"
      else
        ptosord = []
        cont = 0
        @locations.each{|loc|
          ptosord << loc
          if(cont > 0)
            i = cont - 1
            while(i >= 0 && ptosord[i].longitude >= loc.longitude)
              if(ptosord[i].longitude > loc.longitude)
                ptosord[i+1] = ptosord[i]
              elsif(ptosord[i].longitude.to_f == loc.longitude.to_f)
                if(ptosord[i].latitude > loc.latitude)
                  ptosord[i + 1] = ptosord[i]
                end
              end
              i -= 1
            end
            ptosord[i + 1] = loc
          end
          cont += 1
        }

        def cross(o, a, b)
          (a.longitude - o.longitude) * (b.latitude - o.latitude) - (a.latitude - o.latitude) * (b.longitude - o.longitude)
        end

        lower = Array.new
        ptosord.each{|pto|
          while lower.length > 1 and cross(lower[-2], lower[-1], pto) <= 0 do lower.pop end
          lower << pto
        }

        upper = Array.new
        ptosord.reverse_each{|pto|
          while upper.length > 1 and cross(upper[-2], upper[-1], pto) <= 0 do upper.pop end
          upper << pto
        }
        aux = lower[0...-1] + upper[0...-1]

        perimetro = 0
        for i in 1..aux.length - 1
          dist = distancia(aux[i-1].latitude,aux[i-1].longitude,aux[i].latitude,aux[i].longitude)
          perimetro += dist
        end
        @peri="El perimetro del casco convexo es: "+perimetro.to_s+" metros"

        @casa.each{ |casa|
          dist = distancia(casa.latitude.to_f,casa.longitude.to_f,aux[0].latitude,aux[0].longitude)
          for i in 1..aux.length - 1
           distest = distancia(casa.latitude.to_f,casa.longitude.to_f,aux[i].latitude,aux[i].longitude)
            if(dist < distest)
              dist = distest
            end
          end
          @lejano = "La distancia entre la casa del usuario y la ubicacion mas alejada es: "+dist.to_s+" metros"
        }
      end
      @locations = aux
    end

  def distancia(lat1,long1,lat2,long2)
    r= 6378.137
    dLat=(lat1-lat2)*Math::PI/180
    dLong=(long1-long2)*Math::PI/180
    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos((lat2)*Math::PI/180) * Math.cos((lat1)*Math::PI/180) * Math.sin(dLong/2) * Math.sin(dLong/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    d = r * c * 1000
    return d
  end

  def ejercicioc
    ruta = params[:rutas]
    @locations = Location.all
    @visitados = []
    if(!ruta.eql?(nil))
      array = JSON.parse(ruta)
      @locations.each{|loc|
        for i in 0..array["route"].length - 1
          dist = distancia(loc.latitude,loc.longitude,array["route"][i]["latitude"],array["route"][i]["longitude"])
          if(dist < 100)
            @visitados << loc
          end
        end
      }
      @visitados.uniq!
    end
  end

  def location_params
    params.require(:location).permit(:latitude, :longitude, :description, :name)
  end
end
