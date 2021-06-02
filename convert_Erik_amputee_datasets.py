import os
import numpy as np
import scipy.signal as sig

def main():

    # load data from original datasets
    amputee_subjs = [1,2,3,4,5]#[2,3,4,7,9,10,11]#[2,3,4,7,8,9,10,11]
    amputee_dir = "SCHEME1v1Dir"
    num_amp_subj = len(amputee_subjs)
    class_list = [1,2,3,4,5,8,10]#[17,18,21,22,25,26,27,28]


    # save data in format that mimics 3DC dataset
    dataset_dir = "Dataset/Amputee_dataset"
    s_id = 1
    for si in range(0, num_amp_subj):
        
        if not os.path.exists(dataset_dir+"/Participant"+str(s_id)):
            os.mkdir(dataset_dir+"/Participant"+str(s_id))
        
        subj_path = os.listdir(amputee_dir+'/A'+str(amputee_subjs[si]))

        for ff in range(0, len(subj_path)):
            class_num = int(subj_path[ff].split("_")[1][1:])
            rep_num   = int(subj_path[ff].split("_")[3][1])
            tri_num   = int(subj_path[ff].split("_")[2][1:])
            real_rep_num = (tri_num-1)*4 + rep_num
            if class_num in class_list:
                data = np.genfromtxt(amputee_dir+'/A'+str(amputee_subjs[si]) + '/' + subj_path[ff],delimiter=',')*1e2
                # only use first 10 channels
                emg_data = data[:,:10]

                if real_rep_num < 17:
                    if not os.path.exists(dataset_dir+"/Participant"+str(s_id)+'/train'):
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/train')
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/train/EMG')
                    
                    real_rep_num   = real_rep_num-1
                    class_num =  class_list.index(class_num)
                    np.savetxt(dataset_dir+"/Participant"+str(s_id)+'/train/EMG/Amp_EMG_gesture_' + str(real_rep_num) + '_' + str(class_num) + '.txt',emg_data,delimiter=',')
                else:
                    if not os.path.exists(dataset_dir+"/Participant"+str(s_id)+'/test'):
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/test')
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/test/EMG')
                    
                    real_rep_num   = real_rep_num - 17
                    class_num =  class_list.index(class_num)
                    np.savetxt(dataset_dir+"/Participant"+str(s_id)+'/test/EMG/Amp_EMG_gesture_' + str(real_rep_num) + '_' + str(class_num) + '.txt',emg_data,delimiter=',')

        s_id = s_id+1



if __name__ == "__main__":
    main()