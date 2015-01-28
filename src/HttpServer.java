import javax.xml.transform.*;
import java.awt.event.FocusEvent;
import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.Scanner;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import com.sun.javafx.collections.MappingChange;
import com.sun.org.apache.xerces.internal.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Created by yar 09.09.2009
 */
public class HttpServer
{
	static class FuncID
	{
		double timeIndex;
		double funcIndex;
		double linkIndex;
		double trueIndex;
		double resultIndex;
	}

	static class Block
	{
		int blockID;
		String mac;
		ArrayList<FuncID> result = new ArrayList<FuncID>();
	}

	static class HostData
	{
		String mac;
		String url;
		int lastBlock;
	}

	static class GenerateBlock
	{
		int blockID;
		String mac;
		long endTime;
		ArrayList<FuncID> result = new ArrayList<FuncID>();
	}

	static class ThreadID
	{
		int blockID;
		Thread thread;

		ThreadID(int blockID, Thread thread)
		{
			this.blockID = blockID;
			this.thread = thread;
		}
	}

	static String outFile = "Blocks.xml";

	static ArrayList<HostData> hostList = new ArrayList<HostData>();

	static ArrayList<Block> blockList = new ArrayList<Block>();

	static ArrayList<Block> waitList = new ArrayList<Block>();

	static ArrayList<GenerateBlock> generateList = new ArrayList<GenerateBlock>();

	static ArrayList<ThreadID> threadList = new ArrayList<ThreadID>();

	static HostData data = new HostData();

	public static void main(String[] args)
	{
		try
		{
			/*InetAddress ip = InetAddress.getLocalHost();
			NetworkInterface network = NetworkInterface.getByInetAddress(ip);
			localMac = network.getHardwareAddress().toString();*/
			data.mac = "localhost";
			data.url = "http://192.168.1.30:8080";


			new Thread(new SocketListener()).start();

			int processorCount = Runtime.getRuntime().availableProcessors();
			for (int i = 0; i < processorCount - 1; i++)
				threadList.add(new ThreadID(i, new Thread()));

			while (true)
			{
				for (int i = 0; i < processorCount; i++)
				{
					ThreadID threadID = threadList.get(i);
					if (!threadID.thread.isAlive())
					{

						int lastID = data.lastBlock;


						for (int j = 0; j < generateList.size(); j++)
						{
							GenerateBlock generateBlock = generateList.get(j);
							if (generateBlock.blockID == threadID.blockID)
							{

								Block block = new Block();
								block.blockID = generateBlock.blockID;
								block.mac = generateBlock.mac;
								block.result = generateBlock.result;

								if (data.lastBlock + 1 == block.blockID)
								{
									blockList.add(block);
									data.lastBlock++;
									for (int k = 0; k < waitList.size(); k++)
									{
										Block block1 = waitList.get(k);
										if (data.lastBlock + 1 == block1.blockID)
										{
											blockList.add(block1);
											waitList.remove(block1);
										}
									}
								} else
									waitList.add(block);
								generateList.remove(generateBlock);
								break;
							}
						}

						for (int j = 0; j < generateList.size(); j++)
						{
							GenerateBlock generateBlock = generateList.get(j);
							if (generateBlock.endTime < System.currentTimeMillis())
								generateList.remove(generateBlock);
						}

						int prevBlockID = data.lastBlock;
						int nextBlockID = data.lastBlock + 1;
						while (nextBlockID != prevBlockID)
						{
							prevBlockID = nextBlockID;
							for (int j = 0; j < generateList.size(); j++)
							{
								GenerateBlock generateBlock = generateList.get(j);
								if (generateBlock.blockID == nextBlockID)
									nextBlockID++;
							}
						}
						GenerateBlock generateBlock = new GenerateBlock();
						generateBlock.mac = data.mac;
						generateBlock.blockID = nextBlockID;
						generateBlock.endTime = System.currentTimeMillis() + 120000;

						generateList.add(generateBlock);

						threadID.thread = new Thread(new Generator(nextBlockID));
						threadID.thread.start();


						String xmlData = getXmlData();
						FileWriter fw = new FileWriter(outFile);
						fw.write(xmlData);
						fw.close();

						for (int j = 0; j < hostList.size(); j++)
						{
							HostData hostData = hostList.get(j);
							sendRequest(hostData.url);
						}


					}
				}
				Thread.sleep(1000);
			}


		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

	public static String getXmlData()
	{
		try
		{
			DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
			Document doc = docBuilder.newDocument();

			Element localhost = doc.createElement("localhost");
			localhost.setAttribute("mac", data.mac);
			localhost.setAttribute("lastBlock", "" + data.lastBlock);
			doc.appendChild(localhost);

			Element hosts = doc.createElement("hosts");
			localhost.appendChild(hosts);
			for (int i = 0; i < hostList.size(); i++)
			{
				HostData hostData = hostList.get(i);
				Element host = doc.createElement("host");
				host.setAttribute("mac", hostData.mac);
				host.setAttribute("url", hostData.url);
				host.setAttribute("lastBlock", "" + hostData.lastBlock);
				hosts.appendChild(host);
			}

			Element blocks = doc.createElement("blocks");
			localhost.appendChild(blocks);

			for (int i = 0; i < blockList.size(); i++)
			{
				if (blockList.get(i).result.size() == 0) continue;
				Element block = doc.createElement("block");
				block.setAttribute("blockID", "" + blockList.get(i).blockID);
				blocks.appendChild(block);
				                                                          +waitList
				Block newBlock = blockList.get(i);
				for (int j = 0; j < newBlock.result.size(); j++)
				{
					FuncID funcID = newBlock.result.get(j);
					Element func = doc.createElement("func");
					func.setAttribute("timeIndex", "" + funcID.timeIndex);
					func.setAttribute("funcIndex", "" + funcID.funcIndex);
					func.setAttribute("linkIndex", "" + funcID.linkIndex);
					func.setAttribute("trueIndex", "" + funcID.trueIndex);
					func.setAttribute("resultIndex", "" + funcID.resultIndex);
					block.appendChild(func);
				}
			}

			Element generateBlocks = doc.createElement("generateBlocks");
			localhost.appendChild(blocks);

			for (int i = 0; i < generateList.size(); i++)
			{
				Element generateBlock = doc.createElement("generateBlock");
				generateBlock.setAttribute("blockID", "" + generateList.get(i).blockID);
				generateBlock.setAttribute("mac", "" + generateList.get(i).mac);
				generateBlock.setAttribute("endTime", "" + generateList.get(i).endTime);
				blocks.appendChild(generateBlock);
			}

			TransformerFactory transformerFactory = TransformerFactory.newInstance();
			Transformer transformer = transformerFactory.newTransformer();
			DOMSource source = new DOMSource(doc);
			StringWriter writer = new StringWriter();
			StreamResult result = new StreamResult(writer);
			transformer.transform(source, result);
			return writer.getBuffer().toString();
		}
		catch (ParserConfigurationException pce)
		{
			pce.printStackTrace();
		}
		catch (TransformerException tfe)
		{
			tfe.printStackTrace();
		}
		return null;
	}

	public static HostData sendRequest(String targetURL)
	{
		String request = getXmlData();

		StringBuffer response = null;
		URL url;
		HttpURLConnection conn = null;
		try
		{
			//Create connection
			url = new URL(targetURL);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Content-Type",
					"application/x-www-form-urlencoded");

			conn.setRequestProperty("Content-Length", "" +
					Integer.toString(request.getBytes().length));
			conn.setRequestProperty("Content-Language", "en-US");

			conn.setUseCaches(false);
			conn.setDoInput(true);
			conn.setDoOutput(true);

			//Send request
			DataOutputStream wr = new DataOutputStream(
					conn.getOutputStream());
			wr.writeBytes(request);
			wr.flush();
			wr.close();

			//Get HostData
			InputStream is = conn.getInputStream();
			BufferedReader rd = new BufferedReader(new InputStreamReader(is));
			String line;
			response = new StringBuffer();
			while ((line = rd.readLine()) != null)
			{
				response.append(line);
				response.append('\r');
			}
			rd.close();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
		finally
		{
			if (conn != null)
				conn.disconnect();
		}

		try
		{
			DOMParser parser = new DOMParser();
			parser.parse(new InputSource(new StringReader(response.toString())));
			Document doc = parser.getDocument();
			Element host = doc.getDocumentElement();

			HostData res = new HostData();
			res.mac = host.getAttribute("mac");
			res.url = targetURL;
			res.lastBlock = Integer.parseInt(host.getAttribute("lastBlock"));

			int pos = -1;
			for (int i = 0; i < hostList.size(); i++)
				if (hostList.get(i).mac == res.mac)
				{
					hostList.set(i, res);
					pos = i;
				}
			if (pos == -1)
				hostList.add(res);


			Element block = (Element) doc.getElementsByTagName("blocks").item(0);
			int pos2 = -1;
			for (int i = 0; i < blockList.size(); i++)
				if (blockList.get(i).blockID == Double.parseDouble(block.getAttribute("blockID")))
				{
					pos2 = i;
					break;
				}
			if (pos2 == -1)
			{
				Block block2 = new Block();
				block2.blockID = Integer.parseInt(block.getAttribute("blockID"));
				NodeList funcs = block.getElementsByTagName("func");
				for (int i = 0; i < funcs.getLength(); i++)
				{
					Node funcNode = funcs.item(i);
					if (funcNode.getNodeType() == Node.ELEMENT_NODE)
					{
						Element funcElement = (Element) funcNode;
						FuncID funcID = new FuncID();
						funcID.timeIndex = Double.parseDouble(funcElement.getAttribute("timeIndex"));
						funcID.funcIndex = Double.parseDouble(funcElement.getAttribute("funcIndex"));
						funcID.linkIndex = Double.parseDouble(funcElement.getAttribute("linkIndex"));
						funcID.trueIndex = Double.parseDouble(funcElement.getAttribute("trueIndex"));
						funcID.resultIndex = Double.parseDouble(funcElement.getAttribute("resultIndex"));
						block2.result.add(funcID);
					}
				}
				if (data.lastBlock + 1 == block2.blockID)
				{
					blockList.add(block2);
					data.lastBlock++;
					for (int k = 0; k < waitList.size(); k++)
					{
						Block block1 = waitList.get(k);
						if (data.lastBlock + 1 == block1.blockID)
						{
							blockList.add(block1);
							waitList.remove(block1);
						}
					}
				} else
					waitList.add(block2);
			}

			NodeList generateBlocksList = doc.getElementsByTagName("genereteBlock");
			for (int i = 0; i < generateBlocksList.getLength(); i++)
			{
				Node gNode = generateBlocksList.item(i);
				if (gNode.getNodeType() == Node.ELEMENT_NODE)
				{
					Element generate = (Element) gNode;
					GenerateBlock newBlock = new GenerateBlock();
					newBlock.mac = generate.getAttribute("mac");
					newBlock.endTime = Integer.parseInt(generate.getAttribute("endTime"));
					newBlock.blockID = Integer.parseInt(generate.getAttribute("blockID"));

					int pos3 = -1;
					for (int j = 0; j < generateList.size(); j++)
					{
						GenerateBlock block2 = generateList.get(j);
						if (block2.blockID == newBlock.blockID)
						{
							if (block2.mac == data.mac)
							{
								generateList.set(j, newBlock);
								for (int k = 0; k < threadList.size(); k++)
								{
									ThreadID threadID = threadList.get(k);
									if (threadID.blockID == newBlock.blockID)
										threadID.thread.stop();
								}
							}
							break;
						}
					}
					if (pos3 == -1)
						generateList.add(newBlock);
				}
			}


			NodeList hosts = doc.getElementsByTagName("host");
			for (int i = 0; i < hosts.getLength(); i++)
			{
				Node gNode = hosts.item(i);
				if (gNode.getNodeType() == Node.ELEMENT_NODE)
				{
					Element hostElement = (Element) gNode;
					HostData newHost = new HostData();
					newHost.mac = hostElement.getAttribute("mac");
					newHost.url = hostElement.getAttribute("url");
					newHost.lastBlock = Integer.parseInt(hostElement.getAttribute("lastBlock"));

					int pos3 = -1;
					for (int j = 0; j < hostList.size(); j++)
					{
						HostData hostData = hostList.get(j);
						if (hostData.mac == newHost.mac)
						{
							hostList.set(i, newHost);
							break;
						}
					}
					if (pos3 == -1)
						hostList.add(newHost);
				}
			}


			return res;
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return null;


	}

	static class SocketListener implements Runnable
	{

		public void run()
		{
			try
			{
				ServerSocket ss = new ServerSocket(8080);
				while (true)
				{
					Socket s = ss.accept();
					System.err.println("Client accepted");
					new Thread(new SocketSendResponse(s)).start();
				}
			}
			catch (Throwable e)
			{
				System.out.println("занят порт 8080");
			}
		}
	}

	static class SocketScanner implements Runnable
	{

		public void run()
		{
			while (hostList.size() == 0)
			{
				for (int i = 0; i < 256; i++)
				{
					String toIP = "localhost";
					HostData response = sendRequest("http://" + toIP + ":8080", -1);
					if (response != null)
					{

						boolean find = false;
						for (int j = 0; j < hostList.size(); j++)
							if (hostList.get(j).mac == response.mac)
							{
								find = true;
								break;
							}

					}

				}
				try
				{
					Thread.sleep(60000);
				}
				catch (InterruptedException e)
				{
					e.printStackTrace();
				}
			}
		}
	}

	static class SocketSendResponse implements Runnable
	{

		private Socket s;
		private InputStream is;
		private OutputStream os;

		private SocketSendResponse(Socket s) throws Throwable
		{
			this.s = s;
			this.is = s.getInputStream();
			this.os = s.getOutputStream();
		}

		public void run()
		{
			try
			{
				readInputHeaders();
				writeResponse(createRequest(0));
			}
			catch (Throwable t)
			{
				/*do nothing*/
			}
			finally
			{
				try
				{
					s.close();
				}
				catch (Throwable t)
				{
					/*do nothing*/
				}
			}
			System.err.println("Client processing finished");
		}

		private void writeResponse(String s) throws Throwable
		{
			String response = "HTTP/1.1 200 OK\r\n" +
					"Server: YarServer/2009-09-09\r\n" +
					"Content-Type: text/html\r\n" +
					"Content-Length: " + s.length() + "\r\n" +
					"Connection: close\r\n\r\n";
			String result = response + s;
			os.write(result.getBytes());
			os.flush();
		}

		private void readInputHeaders() throws Throwable
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(is));
			while (true)
			{
				String s = br.readLine();
				if (s == null || s.trim().length() == 0)
				{
					break;
				}
			}
		}
	}

	static class Generator implements Runnable
	{
		static class Time
		{
			double func;
			double par1;
			double par2;
			double trueto;
			double result;
		}

		int blockID;
		int blockSize = 200;

		Generator(int blockID)
		{
			this.blockID = blockID;
		}

		public void run()
		{

			double funcRun = 0;
			double[] inputVars = {1, 6, 3};


			//set time
			double timeIndex = 3;

			long beginTime = System.currentTimeMillis();
			while (true)
			{
				timeIndex++;
				//timeIndex =4;

				+funcINdexBegin
				+funcindexend

				ArrayList<Time> timeLine = new ArrayList<Time>();
				for (double i = 0; i <= timeIndex; i++)
					timeLine.add(new Time());

				//set function
				double funcCount = 8;

				for (double funcIndex = 0; funcIndex < Math.pow(funcCount, timeIndex); funcIndex++)
				{


					funcRun++;

					if (funcRun % 200 == 0)
					{
						System.out.println(timeIndex + " line " + funcRun + " count " + (System.currentTimeMillis() - beginTime) + " ms");
						beginTime = System.currentTimeMillis();
					}

					double funcIndex2 = funcIndex;
					/*0 * Math.pow(funcCount, 0) + //add
											   1 * Math.pow(funcCount, 1) + //sub
											   4 * Math.pow(funcCount, 2) + //==
											   5 * Math.pow(funcCount, 3) + //!=
											   2 * Math.pow(funcCount, 4); //mul */

					for (double i = 0; i < timeLine.size(); i++)
					{
						Time time = timeLine.get((int) i);
						double razm = Math.pow(funcCount, i + 1);
						time.func = (funcIndex2 % razm) / Math.pow(funcCount, i);
						funcIndex2 -= funcIndex2 % razm;
					}


					//prepare to params generate


					ArrayList<Double> maxIndex = new ArrayList<Double>();
					for (double i = 0; i < timeLine.size(); i++)
						maxIndex.add(Math.pow(inputVars.length + i, 2));
					Double maxIndexSum = 0.0;
					for (double i = 0; i < maxIndex.size(); i++)
						maxIndexSum += maxIndex.get((int) i);
					ArrayList<Double> valIndex = new ArrayList<Double>();
					for (double i = 0; i < maxIndex.size(); i++)
						valIndex.add(0.0);


					//set params
					for (double parIndex = 0; parIndex < maxIndexSum; parIndex++)
					{

						double parIndex2 = parIndex;
						/*(0 + 2 * Math.sqrt(maxIndex.get(0))) * 1 +
								   (3 + 2 * Math.sqrt(maxIndex.get(1))) * 1 * maxIndex.get(1) +
								   (0 + 0 * Math.sqrt(maxIndex.get(2))) * 1 * maxIndex.get(1) * maxIndex.get(2) +
								   (5 + 5 * Math.sqrt(maxIndex.get(3))) * 1 * maxIndex.get(1) * maxIndex.get(2) * maxIndex.get(3) +
								   (6 + 1 * Math.sqrt(maxIndex.get(4))) * 1 * maxIndex.get(1) * maxIndex.get(2) * maxIndex.get(3) * maxIndex.get(4);
									*/
						for (double i = 0; i < valIndex.size(); i++)
						{
							double razm = 1;
							for (double j = 1; j < maxIndex.size() - i; j++)
								razm *= maxIndex.get((int) j);
							double val = (double) (int) (parIndex2 / razm);
							valIndex.set((int) (maxIndex.size() - i - 1), val);
							parIndex2 -= val * razm;

							if (val == 15)
							{
								double x = 1;
							}
							/*double razm = Math.pow(funcCount, i + 1);
										   time.func = (funcIndex2 % razm) / Math.pow(funcCount, i);
										   funcIndex2 -= funcIndex2 % razm;
										   */
						}

						for (double i = 0; i < valIndex.size(); i++)
						{
							double val = valIndex.get((int) i);
							Time time = timeLine.get((int) i);
							double razm = Math.pow(funcCount, i + 1);
							time.par1 = (int) (val % Math.sqrt(maxIndex.get((int) i)));
							time.par2 = (int) (val / Math.sqrt(maxIndex.get((int) i)));
						}


						//set trueto
						ArrayList<Double> equalsFuncIndexes = new ArrayList<Double>();
						for (double i = 0; i < timeLine.size(); i++)
							if (timeLine.get((int) i).func > 3)
								equalsFuncIndexes.add((double) i);

						for (double trueIndex = 0; trueIndex < Math.pow(timeLine.size() - 1, equalsFuncIndexes.size()); trueIndex++)
						{
							double trueIndex2 = trueIndex;
							// 1 + 3 * Math.pow(timeLine.size() - 1, 1);

							for (double i = 0; i < equalsFuncIndexes.size(); i++)
							{
								Time time = timeLine.get((int) equalsFuncIndexes.get((int) i).doubleValue());
								double razm = Math.pow(timeLine.size() - 1, i + 1);
								time.trueto = (trueIndex2 % razm) / Math.pow(timeLine.size() - 1, i);
								trueIndex2 -= trueIndex2 % razm;
								if (time.trueto >= equalsFuncIndexes.get((int) i))
									time.trueto++;
							}


							//run


							double maxRunTime = 10000;
							double runTime = 0;
							double i = 0;
							while ((i < timeLine.size()) & (runTime < maxRunTime))
							{
								runTime++;
								Time time = timeLine.get((int) i);

								double par1 = 0;
								if (time.par1 < inputVars.length)
									par1 = inputVars[(int) time.par1];
								else
									par1 = timeLine.get((int) time.par1 - inputVars.length).result;

								double par2 = 0;
								try
								{
									if (time.par2 < inputVars.length)
										par2 = inputVars[(int) time.par2];
									else
										par2 = timeLine.get((int) time.par2 - inputVars.length).result;
								}
								catch (IndexOutOfBoundsException e)
								{
									e.printStackTrace();
								}

								switch ((int) time.func)
								{
									case 0:
										time.result = par1 + par2;
										break;
									case 1:
										time.result = par1 - par2;
										break;
									case 2:
										time.result = par1 * par2;
										break;
									case 3:
										time.result = par1 / par2;
										break;
									case 4:
										time.result = (par1 == par2) ? 1 : 0;
										break;
									case 5:
										time.result = (par1 != par2) ? 1 : 0;
										break;
									case 6:
										time.result = (par1 > par2) ? 1 : 0;
										break;
									case 7:
										time.result = (par1 < par2) ? 1 : 0;
										break;
								}
								if (time.func > 3)
									if (time.result == 1)
									{
										i = (double) time.trueto;
										continue;
									}

								i++;
							}


							double rightResult = 3.14;
							if (runTime < maxRunTime)
							{
								for (double resultIndex = 0; resultIndex < timeLine.size(); resultIndex++)
								{
									Time time = timeLine.get((int) resultIndex);
									double roundResult = Math.round(time.result * 100.0) / 100.0;
									if (roundResult == rightResult)
									{
										FuncID funcID = new FuncID();
										funcID.timeIndex = timeIndex;
										funcID.funcIndex = funcIndex;
										funcID.linkIndex = parIndex;
										funcID.trueIndex = trueIndex;
										funcID.resultIndex = resultIndex;

										for (int j = 0; j < generateList.size(); j++)
											if (generateList.get(j).blockID == blockID)
												generateList.get(j).result.add(funcID);

									}

								}
							}

						}
					}
				}
			}
		}
	}


}
