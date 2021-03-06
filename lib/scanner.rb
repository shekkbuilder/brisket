class Scanner
  class << self
    def random_seed
      Random.new_seed
    end

    def rate
      "1337" #restriction by the service provider is 4000/second
    end

    def rate_virt
      "2337"
    end

    def rate_cmd_virt
      " --rate " + rate_virt
    end

    def rate_cmd
      " --rate " + rate
    end

    def masscmd
      "/usr/local/sbin/masscan"
    end

    def mass scans
      scans.shuffle.each do |a|
        #system(masscmd + " -c " + Directories.conf_dir + a + Directories.exclude_file_cmd)
        system(masscmd + " -c " + Directories.conf_dir + a + " --open --banners --nocapture cert" + Directories.exclude_file_cmd)
      end    
    end



    def nmapcmd
    	"/usr/bin/nmap"
    end
    
    def nmap_options
    	" -sS -Pn -n --max-rate "+rate+" --open --randomize-hosts "
    	#" -sS -P0 -n -O --osscan-limit --version-light --max-rate "+rate+" --randomize-hosts --open --reason"
    end

    def nmap_virt_options
      " -sS -Pn -n --max-rate "+rate_virt+" --open --randomize-hosts "
    end
    
    def nmap_input_file
    	" -iL " + Directories.data_dir
    end
    
    def nmap_flags
    	nmap_options+nmap_input_file
    end
    
    def nmap scans
      scans.shuffle.each do |a|
        system(nmapcmd + " -p " + Ports.remote_ports + nmap_flags + a + Directories.exclude_file_cmd + " " + Directories.results_out + Naming.hostname + "_" + Options.prefix[1] + "_" + a.gsub(/.ip/, '') + Options.postfix[2])
      end
    end

    def nmap_virt_ip
      Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}.ip_address
    end

    def nmap_eth
      "venet0:0"
    end

    def nmap_virt_flags
      nmap_virt_options + nmap_input_file
      #nmap_virt_options + " -e \""+nmap_eth+"\" -S "+nmap_virt_ip+nmap_input_file
    end

    def nmap_virt scans
      scans.shuffle.each do |a|
        system(nmapcmd + " -p " + Ports.all_ports + nmap_virt_flags + a + Directories.exclude_file_cmd + " " + Directories.results_out + Naming.hostname + "_" + Options.prefix[3] + "_" + a.gsub(/.ip/, '') + Options.postfix[2])
      end
    end

    def nmap_virt_host scans
      scans.shuffle.each do |a|
        system(nmapcmd + " -sL --randomize-hosts --max-rate "+rate_virt+ nmap_input_file + a + Directories.exclude_file_cmd + " " + Directories.results_out + Naming.hostname + "_" + Options.prefix[4] + "_" + a.gsub(/.ip/, '') + Options.postfix[2])
      end
    end

    def nmap_virt_ping scans
      scans.shuffle.each do |a|
        system(nmapcmd + " -PO -n -sn --randomize-hosts --max-rate "+rate_virt+nmap_input_file + a + Directories.exclude_file_cmd + " " + Directories.results_out + Naming.hostname + "_" + Options.prefix[4] + "_" + a.gsub(/.ip/, '') + Options.postfix[2])
      end
    end


    def zmapcmd
      "/usr/local/sbin/zmap"
    end
    
    def zmap_seed
      " -e "+random_seed.to_s
    end
    
    def output_filter
      "--output-filter=\"success = 1\" "
    end

    def verbosity
      " -q" #quiet
    end

    def zmap_rate_cmd
      " -r " + rate
    end
    
    def zmap scans
      scans.shuffle.each do |a|
        Ports.all_ports_ary.each do |b|
          system(zmapcmd + " -p " + b + zmap_seed + zmap_rate_cmd + verbosity + " -w " + Directories.data_dir + a + " -b " + Directories.blacklist + " -O json " +output_filter+ "-o " + Directories.results_dir_date + Naming.hostname + "_" + Options.prefix[2] + "_" + a.gsub(/.ip/, '') + "_port_" + b + Options.postfix[3])
        end
      end    
    end
  end
end
