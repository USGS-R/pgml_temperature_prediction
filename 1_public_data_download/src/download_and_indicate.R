download_and_indicate <- function(remote_ind, local_file, url) {
  download.file(url = url, destfile = local_file)
  gd_put(remote_ind = remote_ind, local_source = local_file, 
         mock_get = "copy")
}